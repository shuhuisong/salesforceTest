// Sansan名刺バッチユーティリティ
public class SansanBatchUtility {
    public Static String LOG_INFO = 'INFO';
    public Static String LOG_ERROR = 'ERROR';

    // 文字列のnull -> 空文字列化処理
    public static String getStr(String s) {
        return (s == null) ? '' : s;
    }

    // 文字列を指定した長さにする処理
    public static String getStr(String s, Integer len) {
        if (String.isNotBlank(s) && len > 0 && s.length() > len) {
            s = s.substring(0, len);
        }
        return getStr(s);
    }

    // 例外内容の文字列を取得する処理。System.debug(e)相当の文字列を生成
    public static String getExceptionString(Exception e) {
        String result = '';

        if (e != null) {
            result = e.getTypeName() + ': ' + e.getMessage();
        }

        return result;
    }

    // DB処理の結果配列の内容連結処理
    public static String getErrorMsg(Database.Error[] errs) {
        String msg ='';
        for (Database.Error err : errs) {
            if (String.isNotBlank(msg) == true) msg += ', ';
            msg += err.getMessage();
        }
        return msg;
    }

    // DateTime型 -> 文字列(yyyy-MM-ddTHH:mm:ssZ)変換処理
    public static String getGmtDateTimeString(DateTime dt) {
        String result = '';
        
        if (dt != null) {
            result = dt.formatGmt('yyyy-MM-dd') + 'T' + dt.formatGmt('HH:mm:ss') + 'Z';
        }

        return result;
    }

    // 日時文字列 -> DateTime変換処理。変換できない場合nullを返却
    public static DateTime parseDateTime(String dateTimeString) {
        DateTime result = null;

        if (String.isNotBlank(dateTimeString)) {
            dateTimeString = dateTimeString.replace('T', ' ');
            dateTimeString = dateTimeString.replaceFirst('\\+.*$', '');

            try {
                result = DateTime.valueof(dateTimeString);
            } catch (Exception e) {
                // ログレコード生成のハンドリングは呼び出し元に任せる
                System.debug(e);
            }
        }

        return result;
    }

    // (疑似)スリープ処理
    public static void sleep(Integer second) {
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        // 指定秒数無処理ループする。サーバリソースの無駄遣いになってしまうが、実装時点のSalesforceワークアラウンドであるためこの実装とする
        while ((finishTime - startTime) < second * 1000) {
            finishTime = DateTime.now().getTime();
        }
    }
    
    // OwnerId取得処理
    public static Id getOwnerUserId(String name) {
        Id result = null;
        List<User> users = [select Id from User where Name = :name order by CreatedDate];
        // 複数件取れた場合は作成日時が古いものを正とする。0件の場合はnullを返却
        if (users.size() > 0) {
            result = users[0].Id;
        }

        return result;
    }

    // SansanApi連携設定を取得し、文字列->文字列のMapを返す処理
    public static Map<String, String> getSettings() {
        List<SansanApiSetting__mdt> listSettings = [select DeveloperName, Value__c from SansanApiSetting__mdt];
        Map<String, String> settings = new Map<String, String>();
        for (SansanApiSetting__mdt setting : listSettings) {
            settings.put(setting.DeveloperName, setting.Value__c);
        }

        System.debug('settings:' + settings);

        return settings;
    }

    // GETリクエスト送信処理
    public static String getRequest(String path, Map<String, String> parameters, String batchName, Map<String, String> settings) {
        String result = null;

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        List<String> queryParameters = new List<String>();

        if (parameters != null) {
            for (String key : parameters.keySet()) {
                queryParameters.add(key + '=' + parameters.get(key));
            }
        }

        String queryParameter = '';

        if (queryParameters.size() > 0) {
            queryParameter = '?' + String.join(queryParameters, '&');
        }

        request.setEndpoint(settings.get('endpoint') + path + queryParameter);
        request.setMethod('GET');
        request.setHeader('X-Sansan-Api-Key', settings.get('apiKey'));
        request.setTimeout(60000);

        System.debug(request);

        try {
            HttpResponse response = http.send(request);
            System.debug(response);

            Integer status = response.getStatusCode();
            String body = response.getBody();

            if (status == 200) {
                result = body;
            } else {
                createLog(LOG_ERROR, batchName, 'Request Error: status code = ' + String.valueOf(status) + ' body: ' +  body);
            }
        } catch (Exception e) {
            System.debug(e);
            createLog(LOG_ERROR, batchName, 'Request Error: ' + getExceptionString(e));
        }

        System.debug(result);

        return result;
    }

    // ログ作成処理
    public static void createLog(String logLevel, String batchName, String message) {
        BatchLog__c batchLog = new BatchLog__c(Type__c = logLevel, BatchName__c = batchName, Message__c = message);

        // ログ出力は異常系の最終処理であるため、例外発生時はデバッグログを出力して握りつぶす
        try {
            insert batchLog;
        } catch (Exception e) {
            System.debug(e);
        }
    }
}