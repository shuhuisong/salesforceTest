// Sansan名刺差分情報取り込みバッチ
public with sharing class SansanNameCardBaseBatch implements Database.Batchable<NameCardData>, Database.Stateful, Database.AllowsCallouts {
    private static String BATCH_NAME = 'SansanNameCardBaseBatch';
    private static final String FIELD_DELIMITER = '\n\n';
    private static String BLANK_STRING = '(なし)';

    // エラーフラグ
    private Boolean hasError { get; set; }

    // バッチ状態
    private String nextPageToken { get; set; }
    private Integer counter { get; set; }
    private Set<String> validUserIds { get; set; }

    // 設定情報
    private Map<String, String> settings { get; set; }

    // コンストラクタ
    public SansanNameCardBaseBatch(Integer counter, String nextPageToken, Set<String> validUserIds) {
        System.debug(counter);
        System.debug(nextPageToken);
        System.debug(validUserIds);

        this.counter = counter;
        this.nextPageToken = nextPageToken;
        this.validUserIds = validUserIds;

        this.hasError = false;
        this.settings = SansanBatchUtility.getSettings();
    }

    // 名刺データを保持して、そこから取引先・取引先責任者レコードを作るクラス
    private class NameCardData {
        public String id { get; set; }
        public String companyId { get; set; }
        public String personId { get; set; }
        public Date exchangeDate { get; set; }
        public DateTime registeredTime { get; set; }
        public DateTime updatedTime { get; set; }
        public String ownerId { get; set; }
        public String lastName { get; set; }
        public String firstName { get; set; }
        public String lastNameReading { get; set; }
        public String firstNameReading { get; set; }
        public String departmentName { get; set; }
        public String title { get; set; }
        public String email { get; set; }
        public String mobile { get; set; }
        public String companyName { get; set; }
        public String postalCode { get; set; }
        public String prefecture { get; set; }
        public String city { get; set; }
        public String street { get; set; }
        public String building { get; set; }
        public String tel { get; set; }
        public String secondTel { get; set; }
        public String fax { get; set; }
        public String url { get; set; }

        public Account account { get; set; }
        public Contact contact { get; set; }

        // 取引先・取引先責任者を作成または更新したか
        public Boolean isProcessedAccountOrContact { get; set; }

        // 取引先DB操作エラーメッセージ
        public String errorMessageOfAccount { get; set; }
        // 取引先責任者DB操作エラーメッセージ
        public String errorMessageOfContact { get; set; }

        // コンストラクタ
        public NameCardData() {
            this.isProcessedAccountOrContact = false;
        }

        // 取引先責任者のマッチキー
        public String getContactKey() {
            return this.companyName + FIELD_DELIMITER + this.personId;
        }

        // 取引先に値をセットする。Sansan側仕様不明のため、IDを除く項目は一律Salesforce側最大幅で切り詰め
        public void setAccount(Account account, Id ownerId) {
            this.isProcessedAccountOrContact = true;

            // 所有者
            account.OwnerId = ownerId;
            // 取引先名
            account.Name = SansanBatchUtility.getStr(this.companyName, 255);
            // 取引先 部門
            account.Site = SansanBatchUtility.getStr(this.departmentName, 80);
            // 取引先 電話
            account.Phone = SansanBatchUtility.getStr(this.tel, 40);
            // 取引先 Fax
            account.Fax = SansanBatchUtility.getStr(this.fax, 40);
            // Web サイト
            account.Website = SansanBatchUtility.getStr(this.url, 255);

            // 現行連携仕様に倣って半角スペースを挟んで連結
            String street = SansanBatchUtility.getStr(this.street) + ' ' + SansanBatchUtility.getStr(this.building);
            // 請求先住所
            account.BillingPostalCode = SansanBatchUtility.getStr(this.postalCode, 20);
            account.BillingState = SansanBatchUtility.getStr(this.prefecture, 80);
            account.BillingCity = SansanBatchUtility.getStr(this.city, 40);
            account.BillingStreet = SansanBatchUtility.getStr(street, 255);

            // 納入先住所
            account.ShippingPostalCode = SansanBatchUtility.getStr(this.postalCode, 20);
            account.ShippingState = SansanBatchUtility.getStr(this.prefecture, 80);
            account.ShippingCity = SansanBatchUtility.getStr(this.city, 40);
            account.ShippingStreet = SansanBatchUtility.getStr(street, 255);

            // 名刺ID
            account.BizCardId__c = this.id;

            // 名刺交換日
            account.BizCardExchangeDate__c = this.exchangeDate;
        }

        // 取引先責任者に値をセットする。Sansan側仕様不明のため、IDを除く項目は一律Salesforce側最大幅で切り詰め
        public void setContact(Contact contact, Id ownerId) {
            this.isProcessedAccountOrContact = true;

            // 取引先
            // 取引先がない状態でここに来た場合、新規はnull・更新で紐付けがあればクリアしない動きとなる
            if (this.account != null) {
                contact.AccountId = this.account.Id;
            }
            // 所有者
            contact.OwnerId = ownerId;
            // 姓
            contact.LastName = SansanBatchUtility.getStr(this.lastName, 80);
            // 名
            contact.FirstName = SansanBatchUtility.getStr(this.firstName, 40);
            // 部署
            contact.Department = SansanBatchUtility.getStr(this.departmentName, 80);
            // 役職
            contact.Title = SansanBatchUtility.getStr(this.title, 128);
            // 電話
            contact.Phone = SansanBatchUtility.getStr(this.tel, 40);
            // 携帯
            contact.MobilePhone = SansanBatchUtility.getStr(this.mobile, 40);
            // その他の電話
            contact.OtherPhone = SansanBatchUtility.getStr(this.secondTel, 40);
            // Fax
            contact.Fax = SansanBatchUtility.getStr(this.fax, 40);
            // メール
            contact.Email = SansanBatchUtility.getStr(this.email, 80);

            // 現行連携仕様に倣って半角スペースを挟んで連結
            String street = SansanBatchUtility.getStr(this.street) + ' ' + SansanBatchUtility.getStr(this.building);
            // 郵送先住所
            contact.MailingPostalCode = SansanBatchUtility.getStr(this.postalCode, 20);
            contact.MailingState = SansanBatchUtility.getStr(this.prefecture, 80);
            contact.MailingCity = SansanBatchUtility.getStr(this.city, 40);
            contact.MailingStreet = SansanBatchUtility.getStr(street, 255);
            // その他住所
            contact.OtherPostalCode = SansanBatchUtility.getStr(this.postalCode, 20);
            contact.OtherState = SansanBatchUtility.getStr(this.prefecture, 80);
            contact.OtherCity = SansanBatchUtility.getStr(this.city, 40);
            contact.OtherStreet = SansanBatchUtility.getStr(street, 255);

            // 名刺ID
            contact.BizCardId__c = this.id;

            // 人物ID
            contact.PersonId__c = this.personId;

            // 名刺交換日
            contact.BizCardExchangeDate__c = this.exchangeDate;
        }

        // 名刺に値をセットする。Sansan側仕様不明のため、IDを除く項目は一律Salesforce側最大幅で切り詰め
        public void setSansanNameCard(SansanNameCard__c sansanNamecard, Id ownerId) {
            // 所有者
            sansanNameCard.OwnerId = ownerId;
            
            // Sansan名刺名
            String compoundName = SansanBatchUtility.getStr(this.lastName) + ' ' + SansanBatchUtility.getStr(this.firstName);
            sansanNameCard.Name = SansanBatchUtility.getStr(compoundName, 80);
            // 名刺ID
            sansanNameCard.NameCardId__c = this.id;
            // 会社ID
            sansanNameCard.CompanyId__c = this.companyId;
            // 人物ID
            sansanNameCard.PersonId__c = this.personId;
            // 名刺交換日
            sansanNamecard.ExchangeDate__c = this.exchangeDate;
            // 名刺登録日時
            sansanNamecard.RegisteredTime__c = this.registeredTime;
            // 名刺更新日時
            sansanNamecard.UpdatedTime__c = this.updatedTime;
            // 所有者ID(Sansan)
            sansanNamecard.OwnerId__c = this.ownerId;
            // 姓
            sansanNamecard.LastName__c = SansanBatchUtility.getStr(this.lastName, 255);
            // 名
            sansanNamecard.FirstName__c = SansanBatchUtility.getStr(this.firstName, 255);
            // 姓カナ
            sansanNameCard.LastNameReading__c = SansanBatchUtility.getStr(this.lastNameReading, 255);
            // 名カナ
            sansanNameCard.FirstNameReading__c = SansanBatchUtility.getStr(this.firstNameReading, 255);
            // 部署名
            sansanNamecard.DepartmentName__c = SansanBatchUtility.getStr(this.departmentName, 255);
            // 役職
            sansanNamecard.Title__c = SansanBatchUtility.getStr(this.title, 255);
            // メールアドレス
            sansanNamecard.Email__c = SansanBatchUtility.getStr(this.email, 255);
            // 携帯番号
            sansanNamecard.Mobile__c = SansanBatchUtility.getStr(this.mobile, 255);
            // 会社名
            sansanNamecard.CompanyName__c = SansanBatchUtility.getStr(this.companyName, 255);
            // 郵便番号
            sansanNamecard.PostalCode__c = SansanBatchUtility.getStr(this.postalCode, 255);
            // 都道府県
            sansanNamecard.Prefecture__c = SansanBatchUtility.getStr(this.prefecture, 255);
            // 市区町村
            sansanNamecard.City__c = SansanBatchUtility.getStr(this.city, 255);
            // 番地
            sansanNamecard.Street__c = SansanBatchUtility.getStr(this.street, 255);
            // ビル名
            sansanNamecard.Building__c = SansanBatchUtility.getStr(this.building, 255);
            // 電話番号
            sansanNamecard.Tel__c = SansanBatchUtility.getStr(this.tel, 255);
            // 電話番号2
            sansanNamecard.SecondTel__c = SansanBatchUtility.getStr(this.secondTel, 255);
            // FAX番号
            sansanNamecard.Fax__c = SansanBatchUtility.getStr(this.fax, 255);
            // URL
            sansanNamecard.Url__c = SansanBatchUtility.getStr(this.url, 255);

            // 取引先
            if (this.account == null) {
                sansanNamecard.Account__c = null;
            } else {
                sansanNamecard.Account__c = this.account.Id;
            }

            // 取引先責任者
            if (this.contact == null) {
                sansanNamecard.Contact__c = null;
            } else {
                sansanNamecard.Contact__c = this.contact.Id;
            }

            // 取引先連携エラーメッセージ
            sansanNameCard.ErrorMessageOfAccount__c = SansanBatchUtility.getStr(this.errorMessageOfAccount, 255);
            // 取引先責任者連携エラーメッセージ
            sansanNameCard.ErrorMessageOfContact__c = SansanBatchUtility.getStr(this.errorMessageOfContact, 255);
        }
    }

    // バッチ初期処理。APIでユーザ情報取得->名刺情報取得後、メイン処理に名刺情報を渡す。
    public Iterable<NameCardData> start(Database.BatchableContext BC) {
        List<NameCardData> nameCardDatas = new List<NameCardData>();

        try {
            // ユーザ情報取得
            procGetUserApi();
            // 名刺情報取得
            nameCardDatas = procGetNameCardApi();

            System.debug(nameCardDatas.size());
            System.debug(nameCardDatas);
        } catch (Exception e) {
            System.debug(e);

            this.hasError = true;
            SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, SansanBatchUtility.getExceptionString(e));
        }

        return nameCardDatas;
    }

    // バッチメイン処理。名刺情報を元に、取引先・取引先責任者・名刺の作成・更新を行う。
    public void execute(Database.BatchableContext info, List<NameCardData> nameCardDatas) {
        if (nameCardDatas == null || nameCardDatas.isEmpty()) {
            return;
        }
        Savepoint sp;

        try {
            sp = Database.setSavepoint();

            Id ownerId = SansanBatchUtility.getOwnerUserId(this.settings.get('ownerUserName')); 

            // 既存の取引先を探して、なければ新規に作る。あれば取引先を更新
            System.debug('procAccount');
            procAccount(nameCardDatas, ownerId);

            // 既存の取引先責任者を探して、なければ新規に作る。あれば取引先責任者を更新
            System.debug('procContact');
            procContact(nameCardDatas, ownerId);

            // 既存の名刺を探して、なければ新規に作る。あれば名刺を更新
            System.debug('procNameCard');
            procNameCard(nameCardDatas, ownerId);
        } catch(Exception e) {
            if (sp != null) {
                Database.rollback(sp);
            }

            this.hasError = true;
            SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, SansanBatchUtility.getExceptionString(e));
        }
    }

    // バッチ終了処理。名刺情報が全て取得できていなければ、トークンを渡して自バッチを呼び出し。
    public void finish(Database.BatchableContext info) {
        try {
            Integer sansanNameCardBaseBatchSize = Integer.valueOf(this.settings.get('sansanNameCardBaseBatchSize'));
            Integer sansanNameCardBaseBatchMaxCount = Integer.valueOf(this.settings.get('sansanNameCardBaseBatchMaxCount'));
            Integer sleepTime = Integer.valueOf(this.settings.get('sleepTime'));

            this.counter += 1;

            Boolean isCountOver = this.counter >= sansanNameCardBaseBatchMaxCount;
            Boolean hasToken = String.isNotBlank(this.nextPageToken);

            if (this.hasError) {
                SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, 'バッチ異常終了');
            } else {
                if (isCountOver && hasToken) {
                    SansanBatchUtility.createLog(SansanBatchUtility.LOG_INFO, BATCH_NAME, 'バッチ正常終了: リミットオーバーのため後続バッチ中止');
                } else if (hasToken) {
                    SansanNameCardBaseBatch batch = new SansanNameCardBaseBatch(this.counter, this.nextPageToken, this.validUserIds);
                    // 2秒スリープ
                    SansanBatchUtility.sleep(sleepTime);
                    SansanBatchUtility.createLog(SansanBatchUtility.LOG_INFO, BATCH_NAME, 'バッチ正常終了: 後続バッチあり(次名刺トークン)');
                    Database.executeBatch(batch, sansanNameCardBaseBatchSize);
                } else {
                    SansanBatchUtility.createLog(SansanBatchUtility.LOG_INFO, BATCH_NAME, 'バッチ正常終了: 後続バッチなし');
                }
            }
        } catch (Exception e) {
            System.debug(e);

            SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, 'バッチ異常終了: ' + SansanBatchUtility.getExceptionString(e));
        }
    }

    // ユーザ情報取得処理
    private void procGetUserApi() {
        // ユーザ情報の取得
        if (this.validUserIds == null) {
            String csvUser = SansanBatchUtility.getRequest('/organization/users', null, BATCH_NAME, this.settings);

            if (csvUser == null) {
                this.hasError = true;
                SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, 'ユーザ情報取得APIエラー');
                return;
            }

            // 現行のAPIの挙動は\r\nが改行コード(仕様上改行を含むレコードは無い想定。行中改行は考慮しない)
            List<String> lines = csvUser.split('\r\n');
            List<List<String>> rows = new List<List<String>>();

            for (String line : lines) {
                if (line.startsWith('"')) {
                    line = line.substring(1);
                }

                if (line.endsWith('"')) {
                    line = line.substring(0, line.length() - 1);
                }

                // 末尾の空白を破棄せずに","区切りで分割
                rows.add(line.split('","', -1));
            }

            Integer userCsvIdIndex = Integer.valueOf(this.settings.get('userCsvIdIndex'));
            Integer userCsvSalesforceImportFlagIndex = Integer.valueOf(this.settings.get('userCsvSalesforceImportFlagIndex'));

            this.validUserIds = new Set<String>();
            for (List<String> row : rows) {
                // 現行仕様では、index値3がuserId。index値20がOrganizationTreeDownloadPrivilege
                // 「組織ツリーをダウンロードできる権限」をSalesforce取り込み対象ユーザ判別フラグとして使用
                // 1が権限あり
                if (row[userCsvSalesforceImportFlagIndex] == '1') {
                    this.validUserIds.add(row[userCsvIdIndex]);
                }
            }
        }

        System.debug(this.validUserIds);
    }

    // 名刺情報取得処理
    private List<NameCardData> procGetNameCardApi() {
        List<NameCardData> result = new List<NameCardData>();

        if (this.validUserIds == null || this.validUserIds.size() == 0) {
            return result;
        }

        Integer sansanNameCardUpdatedDayRange = Integer.valueOf(this.settings.get('sansanNameCardUpdatedDayRange'));
        Date startExchangeDate = Date.valueOf(this.settings.get('startExchangeDate'));

        Map<String, String> params = new Map<String, String>();

        // 取得終了日時
        params.put('updatedFrom', SansanBatchUtility.getGmtDateTimeString(Datetime.now() - sansanNameCardUpdatedDayRange));
        // 取得終了日時
        params.put('updatedTo', SansanBatchUtility.getGmtDateTimeString(Datetime.now()));
        // entryStatusはデフォルトcompletedなので指定しない
        // range
        params.put('range', 'all');
        // 最大数
        params.put('limit', this.settings.get('sansanNameCardApiLimit'));

        if (String.isNotBlank(this.nextPageToken)) {
            params.put('nextPageToken', this.nextPageToken);
        }

        String apiResult = SansanBatchUtility.getRequest('/bizCards', params, BATCH_NAME, this.settings);

        if (apiResult == null) {
            this.hasError = true;
            SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, '名刺情報取得APIエラー');
            return result;
        }

        Map<String, Object> jsonResults = (Map<String, Object>) JSON.deserializeUntyped(apiResult);
        this.nextPageToken = (String) jsonResults.get('nextPageToken');
        List<Object> datas = (List<Object>) jsonResults.get('data');

        for (Object data : datas) {
            Map<String, Object> dataMap = (Map<String, Object>) data;

            // Salesforce取り込みが有効なユーザの名刺かチェック
            Object owner = dataMap.get('owner');
            String ownerId = null;
            if (owner != null) {
                Map<String, Object> castedOwner = (Map<String, Object>) owner;
                ownerId = (String) castedOwner.get('id');
            }

            if (! validUserIds.contains(ownerId)) {
                continue;
            }

            NameCardData nameCardData = new NameCardData();

            // 名刺ID
            nameCardData.id = (String) dataMap.get('id');
            // 会社ID
            nameCardData.companyId = (String) dataMap.get('companyId');
            // 人物ID
            nameCardData.personId = (String) dataMap.get('personId');
            // 名刺交換日(YYYY-MM-DD)
            String exchangeDate = (String) dataMap.get('exchangeDate');
            if (String.isNotBlank(exchangeDate)) {
                try {
                    nameCardData.exchangeDate = Date.valueof(exchangeDate);
                } catch (Exception e) {
                    System.debug(e);
                }
            } else {
                nameCardData.exchangeDate = null;
            }

            // 名刺交換日が未設定か取り込み対象名刺交換日(以降)以前の場合当該名刺はスキップ
            if (nameCardData.exchangeDate == null || nameCardData.exchangeDate < startExchangeDate) {
                continue;
            }

            // 名刺登録日時(YYYY-MM-DD)
            String registeredTime = (String) dataMap.get('registeredTime');
            if (String.isNotBlank(registeredTime)) {
                nameCardData.registeredTime = SansanBatchUtility.parseDateTime(registeredTime);
            } else {
                nameCardData.registeredTime = null;
            }
            // 名刺更新日時(YYYY-MM-DD)
            String updatedTime = (String) dataMap.get('updatedTime');
            if (String.isNotBlank(updatedTime)) {
                nameCardData.updatedTime = SansanBatchUtility.parseDateTime(updatedTime);
            } else {
                nameCardData.updatedTime = null;
            }
            // 所有者(Sansan上の所有者ID)
            nameCardData.ownerId = ownerId;
            // 姓
            nameCardData.lastName = (String) dataMap.get('lastName');
            // 名
            nameCardData.firstName = (String) dataMap.get('firstName');
            // 姓カナ
            nameCardData.lastNameReading = (String) dataMap.get('lastNameReading');
            // 名カナ
            nameCardData.firstNameReading = (String) dataMap.get('firstNameReading');
            // 部署名
            nameCardData.departmentName = (String) dataMap.get('departmentName');
            // 役職
            nameCardData.title = (String) dataMap.get('title');
            // メールアドレス
            nameCardData.email = (String) dataMap.get('email');
            // 携帯番号
            nameCardData.mobile = (String) dataMap.get('mobile');
            // 会社名
            nameCardData.companyName = (String) dataMap.get('companyName');
            // 郵便番号
            nameCardData.postalCode = (String) dataMap.get('postalCode');
            // 都道府県
            nameCardData.prefecture = (String) dataMap.get('prefecture');
            // 市区町村
            nameCardData.city = (String) dataMap.get('city');
            // 番地
            nameCardData.street = (String) dataMap.get('street');
            // ビル名
            nameCardData.building = (String) dataMap.get('building');
            // 電話番号
            nameCardData.tel = (String) dataMap.get('tel');
            // 電話番号2
            nameCardData.secondTel = (String) dataMap.get('secondTel');
            // FAX番号
            nameCardData.fax = (String) dataMap.get('fax');
            // URL
            nameCardData.url = (String) dataMap.get('url');

            result.add(nameCardData);
        }

        return result;
    }

    // 既存の取引先を探して、取引先名が一致するものがなければ、追加
    private void procAccount(List<NameCardData> nameCardDatas, Id ownerId) {
        Id defaultRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName()
            .get(this.settings.get('accountRecordTypeName')).getRecordTypeId();

        Set<String> companyNames = new Set<String>();

        for (NameCardData nameCardData : nameCardDatas) {
            if (String.isNotBlank(nameCardData.companyName)) {
                companyNames.add(nameCardData.companyName);
            }
        }

        // 法人のみ対象
        List<Account> accounts = [SELECT Id, Name, BizCardExchangeDate__c FROM Account
            WHERE Name IN :companyNames AND RecordType.IsPersonType = false
            ORDER BY LastModifiedDate];

        Map<String, Account> companyName2Account = new Map<String, Account>();

        for (Account account : accounts) {
            companyName2Account.put(account.Name, account);
        }

        Map<String, NameCardData> insertMap = new Map<String, NameCardData>();
        Map<String, NameCardData> updateMap = new Map<String, NameCardData>();

        for (NameCardData nameCardData : nameCardDatas) {
            if (String.isBlank(nameCardData.companyName)) {
                nameCardData.errorMessageOfAccount = '名刺に必要項目が不足しているため取引先登録スキップ';
                continue;
            }

            Account targetAccount = companyName2Account.get(nameCardData.companyName);
 
            if (targetAccount == null) {
                targetAccount = new Account(RecordTypeId = defaultRecordTypeId);
                nameCardData.setAccount(targetAccount, ownerId);

                insertMap.put(nameCardData.companyName, nameCardData);

                // 挿入予定のAccountをupdate対象に追加
                companyName2Account.put(nameCardData.companyName, targetAccount);
            } else if (
                targetAccount.BizCardExchangeDate__c == null ||
                targetAccount.BizCardExchangeDate__c < nameCardData.exchangeDate
            ) {
                if (insertMap.keySet().contains(nameCardData.companyName)) {
                    insertMap.put(nameCardData.companyName, nameCardData);
                } else {
                    updateMap.put(nameCardData.companyName, nameCardData);
                }

                // 名刺交換日が新しい場合のみ更新
                // 内容に変更がなくても必ず更新する仕様とする
                nameCardData.setAccount(targetAccount, ownerId);
            }

            nameCardData.account = targetAccount;
        }

        // 新規作成
        if (insertMap.size() > 0) {
            List<Account> accountsToInsert = new List<Account>();
            List<NameCardData> nameCardDataToInsert = new List<NameCardData>();

            for (String key : insertMap.keySet()) {
                accountsToInsert.add(companyName2Account.get(key));
                nameCardDataToInsert.add(insertMap.get(key));
            }

            Database.SaveResult[] results = Database.insert(accountsToInsert, false);
            System.debug(results);

            String errorMessage = '';
            for (Integer n = 0; n < results.size(); n++) {
                if (results[n].isSuccess() == false) {
                    nameCardDataToInsert[n].errorMessageOfAccount = SansanBatchUtility.getErrorMsg(results[n].getErrors());
                    errorMessage += SansanBatchUtility.getErrorMsg(results[n].getErrors()) + '\n';
                }
                if (String.isNotBlank(errorMessage)) {
                    System.debug(errorMessage);
                    SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, '取引先insertエラー: ' + errorMessage);
                }
            }
        }
        System.debug(insertMap);

        // 更新
        if (updateMap.size() > 0) {
            List<Account> accountsToUpdate = new List<Account>();
            List<NameCardData> nameCardDataToUpdate = new List<NameCardData>();

            for (String key : updateMap.keySet()) {
                accountsToUpdate.add(companyName2Account.get(key));
                nameCardDataToUpdate.add(updateMap.get(key));
            }

            Database.SaveResult[] results = Database.update(accountsToUpdate, false);
            System.debug(results);

            String errorMessage = '';
            for (Integer n = 0; n < results.size(); n++) {
                if (results[n].isSuccess() == false) {
                    nameCardDataToUpdate[n].errorMessageOfAccount = SansanBatchUtility.getErrorMsg(results[n].getErrors());
                    errorMessage += SansanBatchUtility.getErrorMsg(results[n].getErrors()) + '\n';
                }
                if (String.isNotBlank(errorMessage)) {
                    System.debug(errorMessage);
                    SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, '取引先updateエラー: ' + errorMessage);
                }
            }
        }
        System.debug(updateMap);
    }

    // 既存の取引先責任者を探して、人物IDが一致するものがなければ、追加
    private void procContact(List<NameCardData> nameCardDatas, Id ownerId) {
        Id defaultRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName()
            .get(this.settings.get('contactRecordTypeName')).getRecordTypeId();

        Set<String> companyNames = new Set<String>();

        for (NameCardData nameCardData : nameCardDatas) {
            if (String.isNotBlank(nameCardData.companyName)) {
                companyNames.add(nameCardData.companyName);
            }
        }

        Set<String> personIds = new Set<String>();

        for (NameCardData nameCardData : nameCardDatas) {
            if (String.isNotBlank(nameCardData.personId)) {
                personIds.add(nameCardData.personId);
            }
        }

        // 個人アカウントは対象外(法人・法人かつ個人が対象)
        List<Contact> contacts = [SELECT Id, Name, Account.Name, PersonId__c, BizCardExchangeDate__c FROM Contact
            WHERE Account.Name IN :companyNames AND PersonId__c IN :personIds AND RecordType.SobjectType = 'Contact'
            ORDER BY LastModifiedDate];

        Map<String, Contact> personId2Contact = new Map<String, Contact>();

        for (Contact contact : contacts) {
            personId2Contact.put(contact.Account.Name + FIELD_DELIMITER + contact.PersonId__c, contact);
        }

        Map<String, NameCardData> insertMap = new Map<String, NameCardData>();
        Map<String, NameCardData> updateMap = new Map<String, NameCardData>();

        System.debug(personId2Contact);

        for (NameCardData nameCardData : nameCardDatas) {
            if (
                // 現行のSansan連携仕様に従い姓:(なし)かつ名:ブランクならスキップ
                String.isBlank(nameCardData.personId) ||
                String.isBlank(nameCardData.lastName) ||
                (BLANK_STRING == nameCardData.lastName && String.isBlank(nameCardData.firstName))
            ) {
                nameCardData.errorMessageOfContact = '名刺に必要項目が不足しているため取引先責任者登録スキップ';
                continue;
            }

            Contact targetContact = personId2Contact.get(nameCardData.getContactKey());
 
            if (targetContact == null) {
                targetContact = new Contact(RecordTypeId = defaultRecordTypeId);
                nameCardData.setContact(targetContact, ownerId);

                insertMap.put(nameCardData.getContactKey(), nameCardData);

                personId2Contact.put(nameCardData.getContactKey(), targetContact);
            } else if (
                // 取引先が紐付けできていない名刺は処理対象外
                nameCardData.account != null &&
                (
                    targetContact.BizCardExchangeDate__c == null ||
                    targetContact.BizCardExchangeDate__c < nameCardData.exchangeDate
                )
            ) {
                if (insertMap.keySet().contains(nameCardData.getContactKey())) {
                    insertMap.put(nameCardData.getContactKey(), nameCardData);
                } else {
                    updateMap.put(nameCardData.getContactKey(), nameCardData);
                }

                // 名刺交換日が新しい場合のみ更新
                // 内容に変更がなくても必ず更新する仕様とする
                nameCardData.setContact(targetContact, ownerId);
            }

            nameCardData.contact = targetContact;
        }

        // 新規作成
        if (insertMap.size() > 0) {
            List<Contact> contactsToInsert = new List<Contact>();
            List<NameCardData> nameCardDataToInsert = new List<NameCardData>();

            for (String key : insertMap.keySet()) {
                contactsToInsert.add(personId2Contact.get(key));
                nameCardDataToInsert.add(insertMap.get(key));
            }

            Database.SaveResult[] results = Database.insert(contactsToInsert, false);
            System.debug(results);

            String errorMessage = '';
            for (Integer n = 0; n < results.size(); n++) {
                if (results[n].isSuccess() == false) {
                    nameCardDataToInsert[n].errorMessageOfContact = SansanBatchUtility.getErrorMsg(results[n].getErrors());
                    errorMessage += SansanBatchUtility.getErrorMsg(results[n].getErrors()) + '\n';
                }
                if (String.isNotBlank(errorMessage)) {
                    System.debug(errorMessage);
                    SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, '取引先責任者insertエラー: ' + errorMessage);
                }
            }
        }
        System.debug(insertMap);

        // 更新
        if (updateMap.size() > 0) {
            List<Contact> contactsToUpdate = new List<Contact>();
            List<NameCardData> nameCardDataToUpdate = new List<NameCardData>();

            for (String key : updateMap.keySet()) {
                contactsToUpdate.add(personId2Contact.get(key));
                nameCardDataToUpdate.add(updateMap.get(key));
            }

            Database.SaveResult[] results = Database.update(contactsToUpdate, false);
            System.debug(results);

            String errorMessage = '';
            for (Integer n = 0; n < results.size(); n++) {
                if (results[n].isSuccess() == false) {
                    nameCardDataToUpdate[n].errorMessageOfContact = SansanBatchUtility.getErrorMsg(results[n].getErrors());
                    errorMessage += SansanBatchUtility.getErrorMsg(results[n].getErrors()) + '\n';
                }
                if (String.isNotBlank(errorMessage)) {
                    System.debug(errorMessage);
                    SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, '取引先責任者updateエラー: ' + errorMessage);
                }
            }
        }
        System.debug(updateMap);
    }

    // 既存の名刺を探して、名刺IDが一致するものがなければ、追加
    private void procNameCard(List<NameCardData> nameCardDatas, Id ownerId) {
        Set<String> nameCardIds = new Set<String>();
        Set<String> accountIds = new Set<String>();
        Set<String> contactIds = new Set<String>();

        for (NameCardData nameCardData : nameCardDatas) {
            if (String.isNotBlank(nameCardData.id)) {
                nameCardIds.add(nameCardData.id);
            }
            if (nameCardData.account != null) {
                accountIds.add(nameCardData.account.id);
            }
            if (nameCardData.contact != null) {
                contactIds.add(nameCardData.contact.id);
            }
        }

        List<SansanNameCard__c> sansanNameCards = [SELECT Id, Name, NameCardId__c, UpdatedTime__c, Account__c, Contact__c FROM SansanNameCard__c
            WHERE NameCardId__c IN :nameCardIds
            ORDER BY LastModifiedDate];

        // 取引先・取引先責任者はマージ処理により消えている可能性があるため取り直す
        Set<Id> existsAccountIds = (new Map<Id, Account>([SELECT Id FROM Account WHERE Id in :accountIds])).keySet();
        Set<Id> existsContactIds = (new Map<Id, Contact>([SELECT Id FROM Contact WHERE Id in :contactIds])).keySet();

        Map<String, SansanNameCard__c> nameCardId2SansanNameCard = new Map<String, SansanNameCard__c>();

        for (SansanNameCard__c sansanNameCard : sansanNameCards) {
            nameCardId2SansanNameCard.put(sansanNameCard.NameCardId__c, sansanNameCard);
        }

        List<SansanNameCard__c> sansanNameCardsToInsert = new List<SansanNameCard__c>();
        List<SansanNameCard__c> sansanNameCardsToUpdate = new List<SansanNameCard__c>();
        List<NameCardData> nameCardDataToInsert = new List<NameCardData>();
        List<NameCardData> nameCardDataToUpdate = new List<NameCardData>();

        for (NameCardData nameCardData : nameCardDatas) {
            SansanNameCard__c targetSansanNameCard = nameCardId2SansanNameCard.get(nameCardData.id);
 
            if (targetSansanNameCard == null) {
                targetSansanNameCard = new SansanNameCard__c();

                nameCardData.setSansanNameCard(targetSansanNameCard, ownerId);

                sansanNameCardsToInsert.add(targetSansanNameCard);
                nameCardDataToInsert.add(nameCardData);
            }  if (
                // 名刺の更新日時が新しいか取引先・取引先責任者を更新した場合のみ更新対象とする
                targetSansanNameCard.UpdatedTime__c == null ||
                targetSansanNameCard.UpdatedTime__c < nameCardData.UpdatedTime ||
                nameCardData.isProcessedAccountOrContact
            ) {
                nameCardData.setSansanNameCard(targetSansanNameCard, ownerId);

                sansanNameCardsToUpdate.add(targetSansanNameCard);
                nameCardDataToUpdate.add(nameCardData);
            }

            if (! existsAccountIds.contains(targetSansanNameCard.Account__c)) {
                targetSansanNameCard.Account__c = null;
            }

            if (! existsContactIds.contains(targetSansanNameCard.Contact__c)) {
                targetSansanNameCard.Contact__c = null;
            }
        }

        if (sansanNameCardsToInsert.size() > 0) {
            Database.SaveResult[] results = Database.insert(sansanNameCardsToInsert, false);
            System.debug(results);

            String errorMessage = '';
            for (Integer n = 0; n < results.size(); n++) {
                if (results[n].isSuccess() == false) {
                    errorMessage += SansanBatchUtility.getErrorMsg(results[n].getErrors()) + '\n';
                }
                if (String.isNotBlank(errorMessage)) {
                    System.debug(errorMessage);
                    SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, '名刺insertエラー: ' + errorMessage);
                }
            }
        }
        System.debug(sansanNameCardsToInsert);

        if (sansanNameCardsToUpdate.size() > 0) {
            Database.SaveResult[] results = Database.update(sansanNameCardsToUpdate, false);
            System.debug(results);

            String errorMessage = '';
            for (Integer n = 0; n < results.size(); n++) {
                if (results[n].isSuccess() == false) {
                    errorMessage += SansanBatchUtility.getErrorMsg(results[n].getErrors()) + '\n';
                }
                if (String.isNotBlank(errorMessage)) {
                    System.debug(errorMessage);
                    SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, '名刺updateエラー: ' + errorMessage);
                }
            }
        }
        System.debug(sansanNameCardsToUpdate);
    }
}