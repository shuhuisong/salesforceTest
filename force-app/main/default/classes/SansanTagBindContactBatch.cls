// Sansanタグ取引先責任者連携バッチ
public with sharing class SansanTagBindContactBatch implements Database.Batchable<sObject>, Database.Stateful {
    private static String BATCH_NAME = 'SansanTagBindContactBatch';
    private static final String FIELD_DELIMITER = '\n\n';

    // エラーフラグ
    private Boolean hasError { get; set; }

    // コンストラクタ
    public SansanTagBindContactBatch() {
        this.hasError = false;
    }

    // バッチ初期処理
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('select Id, Account.Name, PersonId__c, TagNames__c from Contact where RecordType.SobjectType = \'Contact\' and PersonId__c != null');
    }

    // バッチメイン処理。取引先責任者にタグ情報の付与を行う
    public void execute(Database.BatchableContext BC, List<Contact> scope) {
        try {
            Set<String> companyNames = new Set<String>();

            for (Contact contact : scope) {
                if (String.isNotBlank(contact.Account.Name)) {
                    companyNames.add(contact.Account.Name);
                }
            }

            Set<String> psersonIds = new Set<String>();

            for (Contact contact : scope) {
                psersonIds.add(contact.PersonId__c);
            }

            // マージ処理の都合上関連が取れるとは限らないため、必ずキー項目で調べ直す
            List<SansanNameCard__c> sansanNameCards =
                [select Id, CompanyName__c, PersonId__c, TagNames__c from SansanNameCard__c where CompanyName__c in :companyNames and PersonId__c in :psersonIds];

            Map<String, Set<String>> personIdTagsMap = new Map<String, Set<String>>(); 

            for (SansanNameCard__c sansanNameCard : sansanNameCards) {
                Set<String> target = personIdTagsMap.get(sansanNameCard.CompanyName__c + FIELD_DELIMITER + sansanNameCard.PersonId__c);
                if (target == null) {
                    target = new Set<String>();
                    personIdTagsMap.put(sansanNameCard.CompanyName__c + FIELD_DELIMITER + sansanNameCard.PersonId__c, target);
                }

                if (String.isNotBlank(sansanNameCard.TagNames__c)) {
                    target.addAll(sansanNameCard.TagNames__c.split(';'));
                }
            }

            List<Contact> contactsToUpdate = new List<Contact>();
            
            for (Contact contact : scope) {
                String key = contact.Account.Name + FIELD_DELIMITER + contact.PersonId__c;

                Set<String> oldTagNames = new Set<String>();
                if (String.isNotBlank(contact.TagNames__c)) {
                    oldTagNames.addAll(contact.TagNames__c.split(';'));
                }

                if (personIdTagsMap.get(key) != null && personIdTagsMap.get(key) != oldTagNames) {
                    // 変更がある場合のみ更新
                    List<String> newTags = new List<String>(personIdTagsMap.get(key));
                    newTags.sort();
                    String newTagNames = String.join(newTags, ';');

                    contact.TagNames__c = newTagNames;
                    contactsToUpdate.add(contact);
                }
            }

            update contactsToUpdate;
        } catch (Exception e) {
            System.debug(e);

            this.hasError = true;
            SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, SansanBatchUtility.getExceptionString(e));
        }
    }

    // バッチ終了処理
    public void finish(Database.BatchableContext BC) {
        try {
            if (this.hasError) {
                SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, 'バッチ異常終了');
            } else {
                SansanBatchUtility.createLog(SansanBatchUtility.LOG_INFO, BATCH_NAME, 'バッチ正常終了');
            }
        } catch (Exception e) {
            System.debug(e);
            SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, 'バッチ異常終了: ' + BATCH_NAME, SansanBatchUtility.getExceptionString(e));
        }
    }
}