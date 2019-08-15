// Salesforce上のマージ履歴を参照し、Marketoの重複リードをマージする処理
global with sharing class MergeMarketoLead implements Schedulable {
    // スケジュールメイン処理
    global void execute(SchedulableContext SC) {
        List<MarketoApiSetting__mdt> listSettings = [select DeveloperName, Value__c from MarketoApiSetting__mdt];
        Map<String, String> settings = new Map<String, String>();
        for (MarketoApiSetting__mdt setting : listSettings) {
            settings.put(setting.DeveloperName, setting.value__c);
        }

        // 分単位で基準時間を作成
        // 設定値がない場合は0分とする(デフォルト)
        Integer bufferMinutes = 0;
        if (String.isNotBlank(settings.get('bufferMinutes'))) {
            bufferMinutes = Integer.valueOf(settings.get('bufferMinutes'));
        }

        Datetime dt = datetime.now() - ((Double)1 / 24 / 60) * bufferMinutes;
        // GMT日付
        String sDatetime = dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.000\'Z\'');
        System.debug('検索基準時刻:' + sDatetime);

        String limitQuery = '';

        if (String.isNotBlank(settings.get('limitCount'))) {
            limitQuery = ' limit ' + settings.get('limitCount');
        }

        List<MergeHistory__c> mergeHistories =
            Database.query(
                'select Id, IsMarketoMerged__c, SrcSfId__c, DstSfId__c, SrcMarketoIds__c, DstMarketoId__c, LastApiMergedDate__c, LastProcessedDate__c,' +
                ' ApiHttpStatusCode__c, ApiErrorCount__c, ApiErrorCode__c, ApiErrorMessage__c' +
                ' from MergeHistory__c' +
                ' where IsMarketoMerged__c = false and CreatedDate < ' + sDatetime + limitQuery
            );

        List<String> sfIds = new List<String>();

        if (mergeHistories.size() > 0) {
            System.debug('マージ履歴処理対象:' + mergeHistories);
        } else {
            System.debug('マージ履歴処理件数0件のため処理をスキップします');
            return;
        }

        for (MergeHistory__c mergeHistory : mergeHistories) {
            sfIds.add(mergeHistory.DstSfId__c);
        }

        System.debug('sfIds:' + sfIds);

        // 取引開始済みの取引先責任者 ID -> リードIDのマップ作成
        List<Lead> leads = [select Id, ConvertedContactId from Lead where ConvertedContactId in :sfIds];
        Map<String, List<String>> leadMap = new Map<String, List<String>>();

        for (Lead lead : leads) {
            if (leadMap.get(lead.ConvertedContactId) == null) {
                leadMap.put(lead.ConvertedContactId, new List<String>());
            } 
            leadMap.get(lead.ConvertedContactId).add(lead.Id);
        }

        System.debug('取引開始済みの取引先責任者 ID -> リードIDのマップ:' + leadMap);

        for (MergeHistory__c mergeHistory : mergeHistories) {
            System.debug('asyncProcess:' + mergeHistory);
            AsyncProcess asyncProcess = new AsyncProcess(mergeHistory, leadMap, settings);
            System.enqueueJob(asyncProcess);
        }
    }

    // 1レコードごとの非同期処理
    private class AsyncProcess implements Queueable, Database.AllowsCallouts {
        private MergeHistory__c mergeHistory;
        private String accessToken = null;
        Map<String, String> settings;
        Map<String, List<String>> leadMap;
        Integer apiHttpStatusCode = null;
        String apiErrorCode = null;
        String apiErrorMessage = null;
        HttpResponse apiResponse = null;
        Map<String, Object> apiResult = null;

        AsyncProcess(MergeHistory__c mergeHistory, Map<String, List<String>> leadMap, Map<String, String> settings) {
            this.mergeHistory = mergeHistory;
            this.leadMap = leadMap;
            this.settings = settings;
        }

        public void execute(QueueableContext context) {
            this.mergeHistory.LastProcessedDate__c = Datetime.now();

            // マージ元SF ID, マージ先SF ID, マージ先SF IDを指すリードに関連するMarketoレコードを全て取得
            String ids = this.mergeHistory.SrcSfId__c;

            ids += ',' + this.mergeHistory.DstSfId__c;

            if (leadMap.get(this.mergeHistory.DstSfId__c) != null) {
                ids += ',' + String.join(leadMap.get(this.mergeHistory.DstSfId__c), ',');
            }

            Map<String, String> params = new Map<String, String> {
                'filterType' => 'SalesforceId__c',
                'filterValues' => ids
            };

            try {
                Boolean isSucceeded = sendMarketoApi('GET', '/rest/v1/leads.json', params, false);
                
                if (! isSucceeded) {
                    throw new ApiException();
                }

                List<Map<String, Object>> marketoLeads = new List<Map<String, Object>>();

                Object obj = this.apiResult.get('result');
                if (obj instanceof List<Object>) {
                    List<Object> listObj = (List<Object>) obj;
                    
                    for (Object objElement : listObj) {
                        if (objElement instanceof Map<String, Object>) {
                            marketoLeads.add((Map<String, Object>)objElement);
                        }
                    }
                }

                List<String> srcMarketoIdList = new List<String>();
                String srcMarketoIds = null;
                String dstMarketoId = null;

                System.debug(this.mergeHistory);
                System.debug(marketoLeads);

                for (Map<String, Object> marketoLead : marketoLeads) {
                    if (marketoLead.get('SalesforceId__c') == this.mergeHistory.DstSfId__c) {
                        dstMarketoId = String.valueOf(marketoLead.get('id'));
                        continue;
                    }

                    if (marketoLead.get('SalesforceId__c') == this.mergeHistory.SrcSfId__c) {
                        srcMarketoIdList.add(String.valueOf(marketoLead.get('id')));
                        continue;
                    }

                    // マージ元として「マージ先」を指しているリードを追加
                    if (
                        leadMap.get(this.mergeHistory.DstSfId__c) != null &&
                        leadMap.get(this.mergeHistory.DstSfId__c).contains((String) marketoLead.get('SalesforceId__c'))
                    ) {
                        srcMarketoIdList.add(String.valueOf(marketoLead.get('id')));
                    }
                }

                if (srcMarketoIdList.size() > 0) {
                    srcMarketoIds = String.join(srcMarketoIdList, ',');
                }

                System.debug('srcMarketoIds:' + srcMarketoIds + ', dstMarketoId:' + dstMarketoId);

                this.mergeHistory.SrcMarketoIds__c = srcMarketoIds;
                this.mergeHistory.DstMarketoId__c = dstMarketoId;

                if (srcMarketoIds == null || dstMarketoId == null) {
                    // Marketo上でIDが見つからない場合は無条件にマージ済みに倒す
                    this.mergeHistory.IsMarketoMerged__c = true;
                } else {
                    params = new Map<String, String> {
                        'leadIds' => srcMarketoIds
                    };

                    isSucceeded = sendMarketoApi('POST', '/rest/v1/leads/' + String.valueOf(dstMarketoId) + '/merge.json', params, false);
                    this.mergeHistory.LastApiMergedDate__c = Datetime.now();

                    if (isSucceeded) {
                        this.mergeHistory.IsMarketoMerged__c = true;
                    } else {
                        throw new ApiException();
                    }
                }

                // 必ず更新
                this.mergeHistory.ApiHttpStatusCode__c = this.apiHttpStatusCode;
                update this.mergeHistory;
            } catch(Exception e) {
                this.mergeHistory.ApiHttpStatusCode__c = this.apiHttpStatusCode;
                if (this.mergeHistory.ApiErrorCount__c == null) {
                    this.mergeHistory.ApiErrorCount__c = 1;
                } else {
                    this.mergeHistory.ApiErrorCount__c += 1;
                }
                this.mergeHistory.ApiErrorCode__c = this.apiErrorCode;

                if (e instanceof ApiException) {
                    this.mergeHistory.ApiErrorMessage__c = getStr(this.apiErrorMessage, 255);
                } else {
                    this.mergeHistory.ApiErrorMessage__c = getStr(e.getMessage(), 255);
                }
                // ここでエラーが起きる場合はスローする
                update this.mergeHistory;
            }
        }

        // トークン取得処理
        private Boolean getToken() {
            // トークン処理
            Http http = new Http();
            HttpRequest request = new HttpRequest();

            Map<String, String> queryParameters =
                new Map<String, String>{
                    'grant_type' => 'client_credentials',
                    'client_id' => settings.get('clientId'),
                    'client_secret' => settings.get('clientSecret')
                };

            if (! sendMarketoApi('GET', '/identity/oauth/token', queryParameters, true)) {
                return false;
            }

            this.accessToken = (String)this.apiResult.get('access_token');

            return String.isNotBlank(this.accessToken);
        }

        // Marketo API送信処理. 成功した場合true, 失敗した場合falseを返す
        private Boolean sendMarketoApi(String method, String apiUrl, Map<String, String> params, Boolean isIdentify) {
            this.apiHttpStatusCode = null;
            this.apiResponse = null;
            this.apiErrorCode = null;
            this.apiErrorMessage = null;
            this.apiResult = null;

            if (! isIdentify && this.accessToken == null && ! getToken()) {
                return false;
            }

            Http http = new Http();
            HttpRequest request = new HttpRequest();

            // クエリ生成
            Map<String, String> queryParameters = new Map<String, String>();
            if (! isIdentify) {
                queryParameters.put('access_token', this.accessToken);
            }

            queryParameters.putAll(params);

            request.setEndpoint(settings.get('endpoint') + apiUrl + '?' + urlEncode(queryParameters));
            request.setMethod(method);
            request.setHeader('Content-Type', 'application/json');

            if (! isIdentify) {
                request.setHeader('Authorization','Bearer ' + this.accessToken);
            }

            Integer count = 0;
            Boolean isRetry = false;
            Boolean isSucceeded = false;
            while (count == 0 || (isRetry && count <= 1)) {
                isRetry = false;
                count += 1;

                // HTTP通信(タイムアウト例外等は呼び出し元で拾う)
                this.apiResponse = http.send(request);
                System.debug('response:' + this.apiResponse + this.apiResponse.getBody());
                
                this.apiHttpStatusCode = this.apiResponse.getStatusCode();

                if (this.apiHttpStatusCode != 200) {
                    return false;
                }

                this.apiResult = (Map<String, Object>) JSON.deserializeUntyped(this.apiResponse.getBody());

                // 認証以外のAPI
                if (isIdentify) {
                    isSucceeded = true;
                } else {
                    if (this.apiResult.get('success') == true) {
                        isSucceeded = true;
                        break;
                    } else {
                        // エラー
                        Object obj = this.apiResult.get('errors');

                        if (obj instanceof List<Object>) {
                            List<Object> listObj = (List<Object>) obj;

                            if (listObj.size() > 0 && listObj[0] instanceof Map<String, Object>) {
                                Map<String, Object> error = (Map<String, Object>) listObj[0];
                                this.apiErrorCode = (String) error.get('code');
                                this.apiErrorMessage = (String) error.get('message');

                                if (this.apiErrorCode == '601' || this.apiErrorCode == '602') {
                                    if (getToken()) {
                                        isRetry = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            return isSucceeded;
        }
    }

    private class ApiException extends Exception {}

    // URLエンコード処理
    private static String urlEncode(Map<String, String> vals) {
        String result = '';
        for(String thisKey : vals.keySet()) {
            String val = String.isBlank(vals.get(thisKey)) ? '' : vals.get(thisKey);
            result += EncodingUtil.urlEncode(thisKey, 'UTF-8') + '=' + EncodingUtil.urlEncode(val, 'UTF-8') + '&';
        }
        return result.removeEnd('&');
    }

    // null => 空文字列処理
    private static String getStr(String s) {
        return (s == null) ? '' : s;
    }

    // 文字列を指定した長さにする
    private static String getStr(String s, Integer len) {
        if (String.isNotBlank(s) && len > 0 && s.length() > len) {
            s = s.substring(0, len);
        }
        return getStr(s);
    }
}