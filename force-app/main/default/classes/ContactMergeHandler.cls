/**--------------------------------------------------------------------------
 * プログラム名 ：取引先責任者のマージ処理ハンドラー
 * 作成日        ：2017/11/07
 * 作成者        ：SunBridge
 * コピーライト   ：株式会社東洋経済新報社　TOYO KEIZAI INC. Limited Copyright (c) 2017
 *----------------------------------------------------------------------------
 * 修正履歴（修正日：担当者：修正内容）
 * 2017/11/07:SunBridge:新規作成
 *----------------------------------------------------------------------------
 */

public without sharing class ContactMergeHandler {

    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;
    public static Boolean isLeadConverting = false;
    public static Boolean isTriggerCalled = false;

    private static Map < Id, Datetime > timeComparison = new Map < Id, Datetime > ();
    /**
     * コンストラクタ
     */
    public ContactMergeHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
        System.debug(LoggingLevel.ERROR, '#M00__：\n①__:' + m_isExecuting + '\n②__:' + BatchSize + '\n③__:' + +'\n④__:' + +'\n⑤:' + 88);
    }

    /**
     * マージ処理
     */
    public void doMerge(Contact[] newObjs, Map < ID, Contact > newMap, Contact[] oldObjs, Map < ID, Contact > oldMap) {
        Savepoint sp = Database.setSavepoint();
        System.debug(LoggingLevel.ERROR, '#M02__：\n①__:' + sp + '\n②__:' + newObjs + '\n③__:' + newObjs.size() + '\n④__:' + +'\n⑤__:' + 88);
        try {
            // キャンペーンIDが設定されている場合処理を分岐する
            boolean hasCampaignId = false;
            for (Contact contact: newObjs) {
                if (! String.isBlank(contact.CampaignId__c)) {
                    hasCampaignId = true;
                }
            }

            if (hasCampaignId) {
                // 関数内部で必ず自身をupdateするため、後続処理は次のトリガ実行時になる
                assignCampaignMember(newObjs);
                return;
            }

            // 新データ中に含まれるEmailと新データ内の東洋経済IDに合致するDBデータ中Emailのリスト
            List < String > emailList = new List < String > ();
            List < String > toyokeizaiIdList = new List < String > ();
            for (Contact tpContact: newObjs) {
                if (String.isNotBlank(tpContact.Email)) {
                    emailList.add(tpContact.Email);
                }
                if (String.isNotBlank(tpContact.ToyokeizaiId__c)) {
                    toyokeizaiIdList.add(tpContact.ToyokeizaiId__c);
                }
            }
            System.debug(LoggingLevel.ERROR, '#M04__：\n①__:' + emailList + '\n②__:' + toyokeizaiIdList + '\n③__:' + new set < String > (emailList) + '\n④__:' + new set < String > (toyokeizaiIdList) + '\n⑤__:' + 88);
            if (emailList.size() == 0 && toyokeizaiIdList.size() == 0) {
                return;
            }
            System.debug(LoggingLevel.ERROR, '#M06：\n①__:' + emailList.size() + '\n②__:' + toyokeizaiIdList.size() + '\n③__:' + new set < String > (emailList) + '\n④__:' + new set < String > (toyokeizaiIdList) + '\n⑤__:' + 88);

            //////// 取引先責任者処理 ////////
            // 同じメールアドレス、東洋経済用会員ID(ToyokeizaiId)の取引先責任者取得
            Map < String, Schema.SObjectField > FieldMap = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
            System.debug(LoggingLevel.ERROR, '#M08：\n①__:' + emailList.size() + '\n②__:' + toyokeizaiIdList.size() + '\n③__:' + new set < String > (emailList) + '\n④__:' + new set < String > (toyokeizaiIdList) + '\n⑤__:' + 88);
            String fieldNames = '';
            // select用のカラムリスト文字列作成処理
            for (String fieldName: fieldMap.keySet()) {
                //System.debug(LoggingLevel.ERROR, '#M16.5_：\n①_:' + fieldName + '\n②_:' + fieldMap + '\n③_:' + fieldMap.get(fieldName) + '\n④_:' + fieldNames + '\n⑤_:' + 88);
                Schema.DescribeFieldResult tpDescribeFieldResult = fieldMap.get(fieldName).getDescribe();
                List < String > columnlList = new List < String > ();
                columnlList.add('lastmodifieddate');
                columnlList.add('id');
                columnlList.add('ispersonaccount');
                Set < String > columnlMap = new Set < String > (columnlList);
                //System.debug(LoggingLevel.ERROR, '#M17_：\n①_:' + fieldName + '\n②_:' + fieldMap + '\n③_:' + tpDescribeFieldResult + '\n④_:' + fieldNames + '\n⑤_:' + 88);
                if ((columnlMap.contains(fieldName) || tpDescribeFieldResult.isUpdateable())) {
                    fieldNames += fieldName + ',';
                }
            }
            System.debug(LoggingLevel.ERROR, '#M10_：\n①_:' + fieldNames + '\n②_:' + emailList + '\n③_:' + toyokeizaiIdList + '\n④_:' + 88 + '\n⑤_:' + 88);
            // 新データとEmail, 東洋経済IDいずれかが合致するデータをDBから取得
            List < Contact > originalContactList = Database.query('SELECT ' + fieldNames + ' Account.RecordTypeId FROM Contact WHERE Email =:emailList OR ToyokeizaiId__c =:toyokeizaiIdList ORDER BY LastModifiedDate ASC,RecordTypeId DESC');
            Map < Id, Contact > originalContactMap = new Map < Id, Contact > (originalContactList);
            System.debug(LoggingLevel.ERROR, '#M12_：\n①_:' + originalContactMap + '\n②_:' + fieldNames + '\n③_:' + originalContactList.size() + '\n④_:' + originalContactList + '\n⑤_:' + 88);

            Set < String > tpEmailSet = new Set < String > (emailList);
            // DBデータを処理
            for (Id tpId: originalContactMap.keySet()) {
                // ID->最終変更日時データを作成
                if (!timeComparison.containsKey(tpId)) {
                    timeComparison.put(tpId, originalContactMap.get(tpId).lastmodifieddate);
                }
                // 東洋経済IDが同一でEmailが異なるデータをemailListに追加しておく(emailList上重複するケースあり)
                if(!tpEmailSet.contains(originalContactMap.get(tpId).Email)){
                    emailList.add(originalContactMap.get(tpId).Email);
                }
            }

            // マージ処理不要内容除去
            // Emailが同じか東洋経済IDが同じデータがDBデータ内に何件あるかをカウントし、2件以上の場合処理対象とする
            Set < Id > removeTarget = new Set < Id > ();
            for (Id tpIdI: originalContactMap.keySet()) {
                Integer counter = 0;
                String emailAddress = originalContactMap.get(tpIdI).Email;
                String toyokeizaiId_c = '';
                if (originalContactMap.get(tpIdI).ToyokeizaiId__c != null) {
                    toyokeizaiId_c = originalContactMap.get(tpIdI).ToyokeizaiId__c;
                }
                for (Id tpIdII: originalContactMap.keySet()) {
                    String toyokeizaiId_cII = '';
                    if (originalContactMap.get(tpIdII).ToyokeizaiId__c != null) {
                        toyokeizaiId_cII = originalContactMap.get(tpIdII).ToyokeizaiId__c;
                    }
                    //System.debug(LoggingLevel.ERROR, '#M14__：\n①__:' + tpIdII + '\n②__:' + originalContactMap.get(tpIdI) + '\n③_:' + toyokeizaiId_c + toyokeizaiId_cII + '\n④__:' + String.isNotBlank(toyokeizaiId_c + toyokeizaiId_cII) + '\n⑤__:' + 88);
                    // Emailが同じか東洋経済IDが設定かつ同じ
                    if (emailAddress == originalContactMap.get(tpIdII).Email || (toyokeizaiId_c == toyokeizaiId_cII && String.isNotBlank(toyokeizaiId_c + toyokeizaiId_cII))) {
                        counter++;
                    }
                }
                // 1件は必ず検出のため、2件以上の場合処理対象
                if (counter < 2) {
                    removeTarget.add(originalContactMap.get(tpIdI).Id);
                }
            }
            System.debug(LoggingLevel.ERROR, '#M16_：\n①_:' + removeTarget + '\n②_:' + removeTarget.size() + '\n③_:' + originalContactMap.size() + '\n④_:' + timeComparison + '\n⑤_:' + emailList);
            // 非重複レコードを削除
            for (Id tpId: removeTarget) {
                originalContactMap.remove(tpId);
                //System.debug(LoggingLevel.DEBUG, '#M22_：\n①_:' + tpId + '\n②_:' + removeTarget + '\n③_:' + originalContactMap + '\n④_:' + 88 + '\n⑤_:' + 88);
            }

            // 処理対象が無い場合、処理終了
            if (originalContactMap.size() == 0) {
                return;
            }
            System.debug(LoggingLevel.ERROR, '#M18__：\n①__:' + 88 + '\n②__:' + originalContactMap + '\n③_:' + originalContactMap.size() + '\n④__:' + 88 + '\n⑤__:' + 88);

            // 処理対象データ格納アレイ
            Map < Id, Contact > processContactMap = new Map < Id, Contact > ();
            for (Id tpId: originalContactMap.keySet()) {
                processContactMap.put(tpId, originalContactMap.get(tpId));
            }
            //取引先更新対象
            List < Account > updateAccountList = new List < Account > ();

            // ToyokeizaiIdが同一、Emailが異なる、レコードが存在する場合、lastmodifieddateが最新であるレコードのEmailの値を同一ToyokeizaiIdを持つレコードのEmailに設定する
            processContactMap = removeDuplicateEmail(processContactMap);

            // Emailが同一、ToyokeizaiIdが異なるレコードが存在する場合、lastmodifieddateが最新であるレコード以外のレコードの「えびす退会日」「えびす削除日」をNULLに設定する
            processContactMap = setNullEbisuTaikaiDate(processContactMap);

            // Emailが重複しているレコード内でのレコードタイプの組み合わせ
            // 取引先責任者レコードタイプID 法人
            Id corporativeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('法人').getRecordTypeId();
            // 取引先責任者レコードタイプID 法人かつ個人
            Id corporateAndPersonlId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('法人かつ個人').getRecordTypeId();
            // 取引先レコードタイプID 法人
            Id accountCorporativeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('法人').getRecordTypeId();
            System.debug(LoggingLevel.ERROR, '#M20__：\n①__:' + corporativeId + '\n②__:' + corporateAndPersonlId + '\n③_:' + accountCorporativeId + '\n④__:' + processContactMap + '\n⑤__:' + 88);

            // 取引先レコードタイプ変更対象
            // 個人取引先の場合の取引先ID保持用変数(MIX)
            Set < Id > accountCorporativeIdSet = new Set < Id > ();
            // 個人取引先の場合の取引先ID保持用変数(単独)
            Set < Id > personAccountIdList = new Set < Id > ();
            // 取引先責任者のタイプ統一、および個人取引先の取引先ID収集
            for (Id tpId: processContactMap.keySet()) {
                // ループ用レコードタイプ一覧
                Set < String > recordTypes = new Set < String > ();

                // ループ用Email
                String emailAddress = processContactMap.get(tpId).Email;
                //  System.debug(LoggingLevel.ERROR, '#M22__：\n①__:' + originalContactMap.get(tpId).Email + '\n②__:' + emailAddress + '\n③_:' + processContactMap.get(tpId).RecordTypeId+ '\n④__:' + originalContactMap.get(tpId).RecordTypeId + '\n⑤__:' + 88);

                // 同一メールアドレスのレコードタイプをリスト化する
                for (Id tpIdII: processContactMap.keySet()) {
                    if (emailAddress == processContactMap.get(tpIdII).Email) {
                        // レコードタイプが設定されている場合のみ処理
                        if (processContactMap.get(tpIdII).RecordTypeId != null) {
                            recordTypes.add(processContactMap.get(tpIdII).RecordTypeId);
                        }

                        // System.debug(LoggingLevel.ERROR, '#M26_：\n①_:' + processContactMap.get(tpIdII).RecordTypeId + '\n②_:' + processContactMap.get(tpIdII).Email + '\n③_:' + originalContactMap.get(tpIdII).Email + '\n④_:' + originalContactMap.get(tpIdII).RecordTypeId + '\n⑤_:' + originalContactMap.size() + '  ' + originalContactMap.size());
                        // 個人取引先の場合、'Person'をレコードタイプに追加
                        if (processContactMap.get(tpIdII).IsPersonAccount) {
                            recordTypes.add('Person');
                        }
                    }
                }
                //  System.debug(LoggingLevel.ERROR, '#M28_：\n①_:' + 88 + '\n②_:' + recordTypes + '\n③_:' + processContactMap + '\n④_:' + emailAddress + '\n⑤_:' + corporativeId + '  ' + corporateAndPersonlId);
                // レコードタイプ一覧に含まれるタイプが(「法人」・「個人」のみ or 「個人」・「法人かつ個人」のみ or 「法人」・「個人」・「法人かつ個人」のみ)である場合
                if (recordTypes.contains('Person') && (recordTypes.contains(corporativeId) || recordTypes.contains(corporateAndPersonlId))) {
                    System.debug(LoggingLevel.ERROR, '#M30_：\n①_:' + recordTypes + '\n②_:' + corporativeId + '\n③_:' + corporateAndPersonlId + '\n④_:' + 88 + '\n⑤_:' + 88);
                    // 個人取引先マージ対象
                    for (Id tpIdIII: processContactMap.keySet()) {
                        // Emailが同一の場合
                        if (emailAddress == processContactMap.get(tpIdIII).Email) {
                            Contact tpContact = processContactMap.get(tpIdIII);
                            // 「法人かつ個人」に差し替え
                            tpContact.RecordTypeId = corporateAndPersonlId;
                            processContactMap.put(tpIdIII, tpContact);
                            System.debug(LoggingLevel.ERROR, '#M32_：\n①_:' + tpContact.Account.RecordTypeId + '\n②_:' + accountCorporativeId + '\n③_:' + tpContact + '\n④_:' + 88 + '\n⑤_:' + 88);
                            // 「法人」以外の場合
                            if (tpContact.Account.RecordTypeId != accountCorporativeId) {
                                // 「個人」 or 「法人かつ個人」の取引先IDを保持
                                accountCorporativeIdSet.add(tpContact.AccountId);
                            }
                        }
                    }
                }
                // レコードタイプ一覧に含まれるタイプが(「法人」のみ or 「法人かつ個人」のみ)である場合
                if (recordTypes.contains(corporativeId) && recordTypes.contains(corporateAndPersonlId)) {
                    for (Id tpIdIII: processContactMap.keySet()) {
                        // Emailが同一の場合
                        if (emailAddress == processContactMap.get(tpIdIII).Email) {
                            Contact tpContact = processContactMap.get(tpIdIII);
                            // 「法人かつ個人」に差し替え
                            tpContact.RecordTypeId = corporateAndPersonlId;
                            processContactMap.put(tpIdIII, tpContact);
                        }
                    }
                }
                // レコードタイプ一覧に含まれるタイプが(「個人」のみ)である場合
                if (recordTypes.contains('Person') && recordTypes.size() == 1) {
                    System.debug(LoggingLevel.ERROR, '#M34_：\n①_:' + recordTypes + '\n②_:' + 88 + '\n③_:' + 88 + '\n④_:' + 88 + '\n⑤_:' + 88);
                    for (Id tpIdIII: processContactMap.keySet()) {
                        // Emailが同一の場合
                        if (emailAddress == processContactMap.get(tpIdIII).Email) {
                            Contact tpContact = processContactMap.get(tpIdIII);
                            // 「個人」の取引先IDを保持
                            personAccountIdList.add(tpContact.AccountId);
                        }
                    }
                }
            }

            // 取引先法人レコードタイプ更新対象整理
            // 「個人」・「法人かつ個人」の取引先責任者レコードについて取引先更新対象リストに追加
            for (Id tpId: accountCorporativeIdSet) {
                updateAccountList.add(
                    new Account(Id = tpId,
                        RecordTypeId = accountCorporativeId));
            }
            System.debug(LoggingLevel.ERROR, '#M36_：\n①_:' + processContactMap + '\n②_:' + personAccountIdList + '\n③_:' + updateAccountList + '\n④_:' + 88 + '\n⑤_:' + 88);

            // 取引先責任者を整理。マージはlastmodifieddateが新しいレコードの値が優先されるように実行する
            for (Id tpId: processContactMap.keySet()) {
                String emailAddress = processContactMap.get(tpId).Email;
                Contact tpContactI = processContactMap.get(tpId);
                // 更新日時が新しいデータのフィールドで更新日時が古いデータのフィールドを上書き
                for (String fieldName: fieldMap.keySet()) {
                    for (Id tpIdI: processContactMap.keySet()) {
                        // Emailが異なる場合は処理しない
                        if (emailAddress != processContactMap.get(tpIdI).Email) {
                            continue;
                        }
                        // Fieldが更新可能でない場合は処理しない
                        Schema.DescribeFieldResult tpDescribeFieldResult = fieldMap.get(fieldName).getDescribe();
                        if (!tpDescribeFieldResult.isUpdateable()) {
                            continue;
                        }
                        //System.debug(LoggingLevel.ERROR, '#M36.5_：\n①_:' + fieldName + '\n②_:' + processContactMap.get(tpIdI).get(fieldName) + '\n③_:' + 88 + '\n④_:' + 88 + '\n⑤_:' + (processContactMap.get(tpIdI).lastmodifieddate < tpContactI.lastmodifieddate && tpContactI.get(fieldName) == null && processContactMap.get(tpIdI).get(fieldName) != null));
                        // 更新日付が新しくFieldの値がnullでない場合上書き
                        if ((processContactMap.get(tpIdI).lastmodifieddate > tpContactI.lastmodifieddate && processContactMap.get(tpIdI).get(fieldName) != null)) {
                            Contact tpContactII = processContactMap.get(tpIdI);
                            // 取引先責任者IDは更新対象外
                            if (!fieldName.toLowerCase().equals('accountid')) {
                                //System.debug(LoggingLevel.ERROR, '#M37_：\n①_:' + fieldName + '\n②_:' + processContactMap.get(tpIdI).get(fieldName) + '\n③_:' + 88 + '\n④_:' + 88 + '\n⑤_:' + 88);
                                tpContactI.put(fieldName, processContactMap.get(tpIdI).get(fieldName));
                            }
                        }
                    }
                }

                // tpContactIから新規作成したtpContactIIに不要なフィールドを除いてデータコピー
                Contact tpContactII = new Contact();
                for (String fieldName: fieldMap.keySet()) {
                    // System.debug(LoggingLevel.ERROR, '#M37.6_：\n①_:' + originalContactMap + '\n②_:' + originalContactMap.get(tpId) + '\n③_:' + fieldName + '\n④_:' + tpId + '\n⑤_:' + processContactMap);
                    // 個人取引先の場合のData.com IDおよび、取引先責任者ID、上司 IDは更新対象外
                    if (originalContactMap.get(tpId).IsPersonAccount && (fieldName.equals('jigsaw') || fieldName.equals('accountid') || fieldName.equals('reportstoid'))) {
                        continue;
                    }
                    Schema.DescribeFieldResult tpDescribeFieldResult = fieldMap.get(fieldName).getDescribe();
                    // Fieldが更新可能でない場合は処理しない
                    if (tpDescribeFieldResult.isUpdateable()) {
                        // 更新日時は処理対象外
                        if (!fieldName.toLowerCase().equals('lastmodifieddate')) {
                        // 個人取引先フラグは処理対象外
                            if (!fieldName.equals('IsPersonAccount')) {
                                tpContactII.put(fieldName, tpContactI.get(fieldName));
                            }
                        }
                    }
                }

                // tpContactIIをprocessContactMapに戻す
                tpContactII.put('Id', tpId);
                processContactMap.put(tpId, tpContactII);
            }
            System.debug(LoggingLevel.ERROR, '#M38_：\n①_:' + processContactMap + '\n②__:' + processContactMap.size() + '\n③_:' + 88 + '\n④_:' + 88 + '\n⑤_:' + 88);

            // 個人取引先の取引先責任者を更新する。
            // 取引先責任者更新対象
            // 個人取引先 -> 「法人かつ個人」以外の場合、取引先責任者更新対象リストに追加
            List < Contact > updateContactList = new List < Contact > ();
            for (Id tpId: processContactMap.keySet()) {
                if (originalContactMap.get(tpId).IsPersonAccount && processContactMap.get(tpId).RecordTypeId != corporateAndPersonlId) {
                    updateContactList.add(processContactMap.get(tpId));
                }
            }
            // 取引先責任者に更新対象がある場合更新
            if (updateContactList.size() > 0) {
                System.debug(LoggingLevel.ERROR, '#M39_：\n①_:' + updateContactList + '\n②__:' + updateContactList.size() + '\n③_:' + +'\n④_:' + +'\n⑤_:' + 88);
                update updateContactList;
            }

            //////// 取引先処理 ////////
            // 個人取引先取引先マージ先取得
            Map < String, Schema.SObjectField > accountFieldMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
            fieldNames = '';
            // select用のカラムリスト文字列作成処理
            for (String fieldName: accountFieldMap.keySet()) {
                // System.debug(LoggingLevel.ERROR, '#M40_：\n①_:' + fieldName + '\n②_:' + fieldMap + '\n③_:' + accountFieldMap.get(fieldName) + '\n④_:' + fieldNames + '\n⑤_:' + 88);
                Schema.DescribeFieldResult tpDescribeFieldResult = accountFieldMap.get(fieldName).getDescribe();
                // 特殊項目
                List < String > columnlList = new List < String > ();
                columnlList.add('lastmodifieddate');
                columnlList.add('id');
                columnlList.add('personcontactid');
                Set < String > columnlMap = new Set < String > (columnlList);
                //System.debug(LoggingLevel.ERROR, '#M42_：\n①_:' + fieldName + '\n②_:' + accountFieldMap + '\n③_:' + tpDescribeFieldResult + '\n④_:' + fieldNames + '\n⑤_:' + 88);
                if (columnlMap.contains(fieldName) || tpDescribeFieldResult.isUpdateable()) {
                    fieldNames += fieldName + ',';
                }
            }
            System.debug(LoggingLevel.ERROR, '#M44_：\n①_:' + fieldNames + '\n②_:' + 88 + '\n③_:' + 88 + '\n④_:' + 88 + '\n⑤_:' + 88);
            List < Account > personAccountList = Database.query('SELECT ' + fieldNames.removeEnd(',') + ' FROM Account WHERE Id =: personAccountIdList ORDER BY LastModifiedDate ASC');
            Map < Id, Account > oriAccountMap = new Map < Id, Account > (personAccountList);
            Map < Id, Account > processAccountMap = new Map < Id, Account > (personAccountList);
            System.debug(LoggingLevel.ERROR, '#M46_：\n①_:' + personAccountList + '\n②__:' + processAccountMap + '\n③__:' + personAccountIdList + '\n④_:' + personAccountList.size() + '\n⑤_:' + timeComparison);

            // 個人取引先の場合、マージはlastmodifieddateが新しいレコードの値が優先されるように実行する
            for (Id tpId: processAccountMap.keySet()) {
                Id tpAccountId = null;
                String emailAddress = processAccountMap.get(tpId).PersonEmail;
                // マージ同一メール
                Account tpAccountI = processAccountMap.get(tpId);
                for (String fieldName: accountFieldMap.keySet()) {
                    for (Id tpIdI: processAccountMap.keySet()) {
                        // Fieldが更新可能でない場合は処理しない
                        if (!accountFieldMap.get(fieldName).getDescribe().isUpdateable()) {
                            continue;
                        }
                        // Emailが異なる場合は処理しない
                        if (emailAddress != processAccountMap.get(tpIdI).PersonEmail) {
                            continue;
                        }
                        Datetime slefTime = timeComparison.get(tpAccountI.PersonContactId);
                        Datetime targetTime = timeComparison.get(processAccountMap.get(tpIdI).PersonContactId);
                        // 最終更新日時が新しくフィールド名がえびす削除フラグ、えびす退会日の場合
                        if (targetTime > slefTime && ((fieldName.equals('ebisudeldate__pc') || fieldName.equals('ebisutaikaidate__pc')))) {
                            tpAccountI.put(fieldName, processAccountMap.get(tpIdI).get(fieldName));
                        }
                        System.debug(LoggingLevel.ERROR, '#M461：\n①_:' + fieldName + '  ' + slefTime + '  ' + targetTime + '\n②_:' + processAccountMap.get(tpIdI).get(fieldName) + '   ' + tpAccountI.PersonContactId + '\n③_:' + +'\n④_:' + +'\n⑤_:' + timeComparison);
                        // 最終更新日時が新しくフィールド値がnullでない場合
                        if (targetTime > slefTime && processAccountMap.get(tpIdI).get(fieldName) != null) {
                            System.debug(LoggingLevel.ERROR, '#M462：\n①_: ' + fieldName);
                            // 不要コード
                            Account tpAccountII = processAccountMap.get(tpIdI);
                            // えびす削除フラグ、えびす退会日、__pc終わり、Person始まり以外の場合
                            if (fieldName.equals('ebisudeldate__pc') || fieldName.equals('ebisutaikaidate__pc') || fieldName.endsWith('__pc') || fieldName.startsWith('Person')) {
                                continue;
                            }
                            tpAccountI.put(fieldName, processAccountMap.get(tpIdI).get(fieldName));
                        }
                    }
                }
                // tpAccountIから、新規作成したtpAccountIIに不要なフィールドを除いてデータコピー
                Account tpAccountII = new Account();
                for (String fieldName: accountFieldMap.keySet()) {
                    Schema.DescribeFieldResult tpDescribeFieldResult = accountFieldMap.get(fieldName).getDescribe();
                    // フィールド名が__pc終わりかperson始まり(ただし、personemail除く)の場合スキップ
                    if ((fieldName.endsWith('__pc') || fieldName.startsWith('person')) && !fieldName.equals('personemail')) {
                        continue;
                    }
                    // フィールドが更新対象かつ最終更新日時・個人取引先フラグ・カスタマーポータルフラグ・名前以外
                    if (
                        tpDescribeFieldResult.isUpdateable() &&
                        !fieldName.toLowerCase().equals('lastmodifieddate') &&
                        !fieldName.equals('IsPersonAccount') &&
                        !fieldName.toLowerCase().equals('iscustomerportal') &&
                        !fieldName.toLowerCase().equals('name')
                    ) {
                        tpAccountII.put(fieldName, tpAccountI.get(fieldName));
                    }
                }

                // tpAccountIIをprocessAccountMapに戻す
                tpAccountII.put('Id', tpId);
                processAccountMap.put(tpId, tpAccountII);
            }
            System.debug(LoggingLevel.ERROR, '#M47_：\n①_:' + processAccountMap + '\n②__:' + +'\n③__:' + +'\n④_:' + 88 + '\n⑤_:' + 88);

            // DMLマージ処理対象整理

            // マージ取引先責任者マップ。構造は、マージ先取引先責任者ID->マージ対象取引先責任者リスト
            Map < Id, List < Contact > > mergeMap = new Map < Id, List < Contact >> ();
            // マージ取引先マップ。構造は、マージ先取引先ID->マージ対象取引先リスト
            Map < Id, List < Account > > personMergeMap = new Map < Id, List < Account >> ();

            Set < String > emailSet = new Set < String > (emailList);
            System.debug(LoggingLevel.ERROR, '#M48_：\n①_:' + emailSet + '\n②_:' + 88 + '\n③_:' + 88 + '\n④_:' + 88 + '\n⑤_:' + 88);

            // Emailごとに、マージ取引先責任者マップ(mergeMap)・マージ取引先マップ(personMergeMap)を作成
            for (String tpEmail: emailSet) {
                // 取引先責任者
                List < Contact > mergeContactList = new List < Contact > ();
                for (Id tpId: processContactMap.keySet()) {
                    String emailAddress = processContactMap.get(tpId).Email;
                    Contact tpContact = processContactMap.get(tpId);
                    if (tpEmail == emailAddress) {
                        mergeContactList.add(tpContact);
                    }
                }
                System.debug(LoggingLevel.ERROR, '#M50_：\n①_:' + tpEmail + '\n②_:' + mergeContactList + '\n③_:' + mergeContactList.size() + '\n④_:' + 88 + '\n⑤_:' + 88);
                if (mergeContactList.size() > 0) {
                    mergeMap.put(mergeContactList.get(0).Id, mergeContactList);
                } else {
                    continue;
                }

                // 取引先
                List < Account > mergeAccountList = new List < Account > ();
                for (Id tpId: processAccountMap.keySet()) {
                    String emailAddress = processAccountMap.get(tpId).PersonEmail;
                    Account tpAccount = processAccountMap.get(tpId);
                    if (tpEmail == emailAddress) {
                        mergeAccountList.add(tpAccount);
                    }
                }

                // 取引先責任者が個人のみの場合(RecordTypeIdに値が設定されたレコードがない場合)、PersonMergeMapにデータを格納
                Boolean personFlag = true;
                for (Contact tpContact: mergeContactList) {
                    if (tpContact.RecordTypeId != null) {
                        personFlag = false;
                    }
                }
                if (personFlag) {
                    personMergeMap.put(mergeAccountList.get(0).Id, mergeAccountList);
                    System.debug(LoggingLevel.ERROR, '#M52_：\n①_:' + personMergeMap + '\n②_:' + mergeAccountList + '\n③_:' + mergeAccountList + '\n④_:' + personFlag + '\n⑤_:' + 88);
                }
            }

            // 取引先更新処理
            if (updateAccountList.size() > 0) {
                update updateAccountList;
            }

            System.debug(LoggingLevel.ERROR, '#M54_：\n①_:' + personMergeMap + '\n②_:' + personMergeMap.size() + '\n③_:' + 88 + '\n④_:' + 88 + '\n⑤_:' + 88);

            // 取引先責任者DMLマージ処理(個人のみでない場合)
            // マージ取引先マップ(mergeAccountMap)。構造は、マージ先取引ID->マージ対象取引先リスト
            Map < Id, Set < Id > > mergeAccountMap = new Map < Id, Set < Id >> ();

            // マージ履歴
            List<MergeHistory__c> mergeHistories = new List<MergeHistory__c>();

            for (Id tpId: mergeMap.keySet()) {
                List < Contact > oriContactList = mergeMap.get(tpId);
                System.debug(LoggingLevel.ERROR, '#M62_：\n①_:' + tpId + '\n②_:' + mergeMap.get(tpId) + '\n③_:' + mergeMap.get(tpId).size() + '\n④_:' + oriContactList + '\n⑤_:' + 88);
                // 個人のみの場合、処理スキップ
                Boolean personFlag = true;
                for (Contact tpContact: oriContactList) {
                    if (tpContact.RecordTypeId != null) {
                        personFlag = false;
                    }
                }
                // 個人取引先フラグだけかマージ対象の取引先責任者リストが1件以下の場合
                if (personFlag || mergeMap.get(tpId).size() <= 1) {
                    continue;
                }

                // マージ先を指定
                Contact tpContact = null;
                tpContact = processContactMap.get(tpId);
                for (Integer i = 0; i < oriContactList.size(); i++) {
                    // if (originalContactMap.get(oriContactList.get(i).Id).ispersonaccount == false) {
                    System.debug(LoggingLevel.ERROR, '#M111_：\n①_:' + oriContactList.size() + '\n②_:' + i + '\n③_:' + oriContactList + '\n④_:' + tpContact + '\n⑤_:' + 88);
                    // oriContactListからマージ先を削除
                    if (oriContactList.get(i).Id == tpContact.Id) {
                        // tpContactへの再代入は不要と思われる
                        tpContact = oriContactList.remove(i);
                        System.debug(LoggingLevel.ERROR, '#M112_：\n①_:' + oriContactList.size() + '\n②_:' + i + '\n③_:' + oriContactList + '\n④_:' + tpContact + '\n⑤_:' + 88);
                        break;
                    }
                }

                System.debug(LoggingLevel.ERROR, '#M113_：\n①_:' + oriContactList.size() + '\n②_:' + +'\n③_:' + oriContactList + '\n④_:' + tpContact + '\n⑤_:' + 88);

                //「法人、法人かつ個人」・個人取引先マージ処理対象整理
                Contact tpContactForHK = null;
                set < Id > tpIds = new set < Id > ();
                List < Contact > oriContactListForHK = new List < Contact > ();
                for (Integer i = 0; i < oriContactList.size(); i++) {
                    oriContactListForHK.add(oriContactList.get(i));
                }
                // 参照する取引先をtpContactForHKにセット
                if (originalContactMap.get(tpContact.Id).IsPersonAccount == true) {
                    // マージ先が個人取引先の場合、マージ元から取引先を持つ取引先責任者を抽出
                    tpIds.add(originalContactMap.get(tpContact.Id).AccountId);
                    while (oriContactListForHK.size() > 0) {
                        // 逐次データ参照用途でremove(0)を使用
                        Contact tpContact3 = oriContactListForHK.remove(0);
                        // 最初の非個人取引先責任者をtpContactForHKにセット
                        if (originalContactMap.get(tpContact3.Id).IsPersonAccount == false) {
                            tpContactForHK = tpContact3;
                            break;
                        }
                    }
                } else {
                    // マージ先が非個人取引先の場合、マージ先の取引先を参照
                    tpContactForHK = tpContact;
                }
                tpIds.add(originalContactMap.get(tpContactForHK.id).AccountId);
                System.debug(LoggingLevel.ERROR, '#M114_：\n①_:' + oriContactList.size() + '\n②_:' + +'\n③_:' + oriContactList + '\n④_:' + tpContact + '\n⑤_:' + 88);
                // マージ元データに個人取引先がある場合、取引先IDを保持
                for (Contact tpCt: oriContactList) {
                    System.debug(LoggingLevel.ERROR, '#M63_：\n①_:' + tpCt + '\n②_:' + originalContactMap.get(tpCt.Id) + '\n③_:' + oriContactList + '\n④_:' + +'\n⑤_:' + 88);
                    if (originalContactMap.get(tpCt.Id).IsPersonAccount == true) {
                        System.debug(LoggingLevel.ERROR, '#M64_：\n①_:' + tpContactForHK.AccountId + '\n②_:' + oriContactList + '\n③_:' + tpIds + '\n④_:' + originalContactMap.get(tpCt.Id).ispersonaccount + '\n⑤_:' + tpCt.AccountId);
                        if (tpCt.AccountId == null) {
                            tpIds.add(originalContactMap.get(tpCt.Id).AccountId);
                        } else {
                            tpIds.add(tpCt.AccountId);
                        }
                    }
                }
                // マージ取引先マップ作成処理
                if (mergeAccountMap.get(tpContactForHK.AccountId) != null) {
                    tpIds.addAll(mergeAccountMap.get(originalContactMap.get(tpContactForHK.Id).AccountId));
                }
                if (tpContactForHK.AccountId == null) {
                    mergeAccountMap.put(originalContactMap.get(tpContactForHK.Id).AccountId, tpIds);
                } else {
                    mergeAccountMap.put(tpContactForHK.AccountId, tpIds);
                }
                System.debug(LoggingLevel.ERROR, '#M68_：\n①_:' + tpContact + '\n②_:' + mergeMap.get(tpId) + '\n③_:' + oriContactList + '\n④_:' + oriContactList.size() + '\n⑤_:' + mergeAccountMap);
                // マージはマージ先1件、マージ元最大2件の組み合わせで実施
                while (oriContactList.size() > 0) {
                    List < Contact > tpContactList = new List < Contact > ();
                    if (oriContactList.size() > 0) {
                        tpContactList.add(oriContactList.remove(0));
                    }
                    if (oriContactList.size() > 0) {
                        tpContactList.add(oriContactList.remove(0));
                    }
                    if (tpContactList.size() > 0) {
                        System.debug(LoggingLevel.ERROR, '#M70_：\n①_:' + tpContact + '\n②_:' + tpContactList + '\n③_:' + tpContactList.size() + '\n④_:' + 88 + '\n⑤_:' + 88);
                        merge tpContact tpContactList;

                        for (Contact contact : tpContactList) {
                            mergeHistories.add(new MergeHistory__c(SrcSfId__c = contact.Id, DstSfId__c = tpContact.Id));
                        }
                    }
                }
            }

            // 取引先責任者DMLマージ処理(個人のみの場合)
            for (Id tpId: personMergeMap.keySet()) {
                System.debug(LoggingLevel.ERROR, '#M56_：\n①_:' + tpId + '\n②_:' + personMergeMap.get(tpId) + '\n③_:' + personMergeMap.get(tpId).size() + '\n④_:' + 88 + '\n⑤_:' + 88);
                List < Account > oriAccountList = personMergeMap.get(tpId);
                // マージはマージ先1件、マージ元最大2件の組み合わせで実施
                while (oriAccountList.size() > 0) {
                    Account tpAccount = oriAccountList.remove(0);
                    List < Account > tpAccountList = new List < Account > ();
                    if (oriAccountList.size() > 0) {
                        tpAccountList.add(oriAccountList.remove(0));
                    }
                    if (oriAccountList.size() > 0) {
                        tpAccountList.add(oriAccountList.remove(0));
                    }
                    System.debug(LoggingLevel.ERROR, '#M58_：\n①_:' + oriAccountList + '\n②_:' + oriAccountList.size() + '\n③_:' + tpAccountList.size() + '\n④_:' + tpAccountList + '\n⑤_:' + 88);
                    if (tpAccountList.size() > 0) {
                        System.debug(LoggingLevel.ERROR, '#M60_:' + tpAccount + '\n②_:' + tpAccountList + '\n③_:' + tpAccountList.size() + '\n④_:' + 88 + '\n⑤_:' + 88);
                        merge tpAccount tpAccountList;

                        for (Account account : tpAccountList) {
                            Account srcAccount = oriAccountMap.get(account.Id);
                            Account dstAccount = oriAccountMap.get(tpAccount.Id);
                        
                            if (srcAccount != null && dstAccount != null) {
                                mergeHistories.add(new MergeHistory__c(SrcSfId__c = srcAccount.PersonContactId, DstSfId__c = dstAccount.PersonContactId));
                            }
                        }
                    }
                }
            }

            // 法人・個人取引先マージ処理
            Set < Id > accountIds = new Set < Id > ();
            for (Id tpId: mergeAccountMap.keySet()) {
                accountIds.addAll(mergeAccountMap.get(tpId));
            }

            // DBから取引先を取得
            System.debug(LoggingLevel.ERROR, '#M72_:_：\n①_' + fieldNames + '\n②_:' + mergeAccountMap + '\n③_:' + accountIds + '\n④_:' + 88 + '\n⑤_:' + 88);
            List < Account > accountList = Database.query('SELECT ' + fieldNames.removeEnd(',') + ' FROM Account WHERE Id =: accountIds ORDER BY LastModifiedDate ASC');
            // 処理対象取引先マップ(processAccountMap)。構造は、マージ先取引ID->マージ対象取引先リスト
            processAccountMap = new Map < Id, Account > (accountList);
            System.debug(LoggingLevel.ERROR, '#M74_：\n①_:' + accountList + '\n②__:' + accountList.size() + '\n③_:' + 88 + '\n④_:' + 88 + '\n⑤_:' + 88);

            // レコードタイプを個人→法人に変更後、マージを行う場合、旧個人の取引先が持つ情報は維持しない(旧個人の取引先が持つ情報はすべてNULLと同様に扱う)
            for (Id tpId: processAccountMap.keySet()) {
                // 「個人」・「法人かつ個人」の場合
                if (accountCorporativeIdSet.contains(tpId)) {
                    Account tpAccount = processAccountMap.get(tpId);
                    Account tpAccountForMap = new Account(Id = tpAccount.Id,
                        Name = null //,tpAccount.Name
                        //OwnerId=tpAccount.OwnerId
                    );
                    processAccountMap.put(tpId, tpAccountForMap);
                    //  System.debug(LoggingLevel.ERROR, '#M76_：\n①_:' + tpAccountForMap + '\n②_:' + processAccountMap.get(tpId) + '\n③_:' + 88 + '\n④_:' + 88 + '\n⑤_:' + 88);
                }
            }

            System.debug(LoggingLevel.ERROR, '#M77_：\n①_:' + processAccountMap + '\n②_:' + 88 + '\n③_:' + mergeAccountMap + '\n④_:' + 88 + '\n⑤_:' + 88);

            // 個人・法人取引先取得の場合、マージはlastmodifieddateが新しいレコードの値が優先されるように実行する
            for (Id tpId: processAccountMap.keySet()) {
                Account tpAccountI = processAccountMap.get(tpId);
                for (String fieldName: accountFieldMap.keySet()) {
                    for (Id tpIdI: processAccountMap.keySet()) {
                        // Fieldが更新可能でない場合は処理しない
                        if (!accountFieldMap.get(fieldName).getDescribe().isUpdateable()) {
                            continue;
                        }
                        // マージ取引先マップのリスト中にループの内・外両方のIDが含まれるものがある場合のみ処理続行
                        Boolean continueFlag = false;
                        for (Id tpIds: mergeAccountMap.keySet()) {
                            if (mergeAccountMap.get(tpIds).contains(tpAccountI.Id) && mergeAccountMap.get(tpIds).contains(processAccountMap.get(tpIdI).Id)) {
                                continueFlag = true;
                            }
                        }
                        if (!continueFlag) {
                            continue;
                        }
                        // id:tpIdIのデータから、tpAccountIに更新可能なFieldのみデータコピー
                        if (processAccountMap.get(tpIdI).lastmodifieddate > tpAccountI.lastmodifieddate && processAccountMap.get(tpIdI).get(fieldName) != null) {
                            // 不要コード
                            Account tpAccountII = processAccountMap.get(tpIdI);
                            Schema.DescribeFieldResult tpDescribeFieldResult = accountFieldMap.get(fieldName).getDescribe();
                            if (tpDescribeFieldResult.isUpdateable()) {
                                tpAccountI.put(fieldName, processAccountMap.get(tpIdI).get(fieldName));
                            }
                        }
                    }
                }
                // tpAccountIから、新規作成したtpAccountIIに不要なフィールドを除いてデータコピー
                // フィールドが更新対象かつ最終更新日時・個人取引先フラグ・カスタマーポータルフラグ・名・性・東洋経済ID・敬称・フィールド名が__pc終わりかPerson始まり以外
                Account tpAccountII = new Account();
                for (String fieldName: accountFieldMap.keySet()) {
                    Schema.DescribeFieldResult tpDescribeFieldResult = accountFieldMap.get(fieldName).getDescribe();
                    //System.debug(LoggingLevel.ERROR, '#M78_：\n①_:' + tpDescribeFieldResult + '\n②__:' + fieldName + '\n③_:' + 88 + '\n④_:' + 88 + '\n⑤_:' + 88);
                    if (
                        tpDescribeFieldResult.isUpdateable() &&
                        !fieldName.toLowerCase().equals('lastmodifieddate') &&
                        !fieldName.equals('IsPersonAccount') &&
                        !fieldName.toLowerCase().equals('iscustomerportal') &&
                        !fieldName.toLowerCase().equals('lastname') &&
                        !fieldName.toLowerCase().equals('firstname') &&
                        !fieldName.toLowerCase().equals('toyokeizaiid__c') &&
                        !fieldName.toLowerCase().equals('salutation') &&
                        !fieldName.startsWith('Person') &&
                        !fieldName.endsWith('__pc')
                    ) {
                        tpAccountII.put(fieldName, tpAccountI.get(fieldName));
                    }
                }
                // tpAccountIIをprocessAccountMapに戻す
                tpAccountII.put('Id', tpId);
                processAccountMap.put(tpId, tpAccountII);
            }

            System.debug(LoggingLevel.ERROR, '#M80_：\n①_:' + mergeAccountMap + '\n②_:' + mergeAccountMap.size() + '\n③_:' + processAccountMap.size() + '\n④_:' + 88 + '\n⑤_:' + 88);
            // 個人法人取引先DMLマージ処理実行
            for (Id tpId: mergeAccountMap.keySet()) {
                Account tpAccount = null;
                List < Account > oriAccountList = new List < Account > ();
                for (id tpAId: processAccountMap.keySet()) {
                    if (tpId == tpAId) {
                        tpAccount = processAccountMap.get(tpId);
                    } else if (mergeAccountMap.get(tpId).contains(tpAId)) {
                        oriAccountList.add(processAccountMap.get(tpAId));
                    }
                }
                System.debug(LoggingLevel.ERROR, '#M82_：\n①_:' + tpId + '\n②_:' + processAccountMap.get(tpId) + '\n③_:' + processAccountMap.size() + '\n④_:' + 88 + '\n⑤_:' + 88);

                // マージはマージ先1件、マージ元最大2件の組み合わせで実施
                while (oriAccountList.size() > 0) {
                    List < Account > tpAccountList = new List < Account > ();
                    if (oriAccountList.size() > 0) {
                        tpAccountList.add(oriAccountList.remove(0));
                    }
                    if (oriAccountList.size() > 0) {
                        tpAccountList.add(oriAccountList.remove(0));
                    }
                    System.debug(LoggingLevel.ERROR, '#M84_：\n①_:' + oriAccountList + '\n②_:' + oriAccountList.size() + '\n③_:' + tpAccountList.size() + '\n④_:' + tpAccountList + '\n⑤_:' + 88);
                    if (tpAccountList.size() > 0) {
                        System.debug(LoggingLevel.ERROR, '#M86_：\n①_:' + tpAccount + '\n②_:' + tpAccountList + '\n③_:' + tpAccountList.size() + '\n④_:' + 88 + '\n⑤_:' + 88);
                        merge tpAccount tpAccountList;
                    }
                }
            }

            System.debug(LoggingLevel.ERROR, '#M87_：\n①_:' + mergeHistories + '\n②_:' + 88 + '\n③_:' + 88 + '\n④_:' + 88 + '\n⑤_:' + 88);
            insert mergeHistories;

            System.debug(LoggingLevel.ERROR, '#M88_：\n①_:' + 88 + '\n②_:' + 88 + '\n③_:' + 88 + '\n④_:' + 88 + '\n⑤_:' + 88);
        } catch (Exception e) {
            // 例外が発生した場合、ロールバック
            Database.rollback(sp);
            System.debug(LoggingLevel.ERROR, '#M90__：\n①__:' + 'ERROR' + e.getMessage() + '\n②__:' + '' + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
        }
    }

    /**
     * lastmodifieddateが最新であるレコードのEmailの値を同一ToyokeizaiIdを持つレコードのEmailに設定する
     */
    private Map < Id, Contact > removeDuplicateEmail(Map < Id, Contact > tpContactMap) {
        // 東洋経済IDでマッチングをかけ、より新しいデータによりEmailを上書きする。本処理後、Emailが設定されているデータはすべて同一の値となる
        for (Id tpId: tpContactMap.keySet()) {
            Datetime tptmodifieddate = tpContactMap.get(tpId).lastmodifieddate;
            String toyokeizaiId_c = tpContactMap.get(tpId).ToyokeizaiId__c;
            // 東洋経済IDのクレンジング(null -> '', trim)
            if (toyokeizaiId_c == null) {
                toyokeizaiId_c = '';
            } else {
                toyokeizaiId_c = toyokeizaiId_c.trim();
            }
            String emailAddress = tpContactMap.get(tpId).Email;
            for (Id tpIdII: tpContactMap.keySet()) {
                String toyokeizaiId_cII = tpContactMap.get(tpIdII).ToyokeizaiId__c;
                // 東洋経済IDのクレンジング(null -> '', trim)
                if (toyokeizaiId_cII == null) {
                    toyokeizaiId_cII = '';
                } else {
                    toyokeizaiId_cII = toyokeizaiId_cII.trim();
                }
                // 東洋経済IDが同一の古いデータのメールアドレスを上書き
                if ((tptmodifieddate >= tpContactMap.get(tpIdII).lastmodifieddate) && (toyokeizaiId_c == toyokeizaiId_cII) && String.isNotBlank(toyokeizaiId_c + toyokeizaiId_cII) && String.isNotBlank(tpContactMap.get(tpId).Email)) {
                    // System.debug(LoggingLevel.ERROR, '#M94__：\n①__:' + toyokeizaiId_c + '\n②__:' + toyokeizaiId_cII + '\n③__:' + emailAddress + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
                    Contact tpContact = tpContactMap.get(tpIdII);
                    tpContact.Email = tpContactMap.get(tpId).Email;
                    tpContactMap.put(tpIdII, tpContact);
                }
            }
        }
        // 東洋経済IDでマッチングをかけ、ブランクEmailを上書きする。Email未設定の場合対策
        for (Id tpId: tpContactMap.keySet()) {
            String toyokeizaiId_c = tpContactMap.get(tpId).ToyokeizaiId__c;
            // 東洋経済IDのクレンジング(null -> '', trim)
            if (toyokeizaiId_c == null) {
                toyokeizaiId_c = '';
            } else {
                toyokeizaiId_c = toyokeizaiId_c.trim();
            }

            if(String.isBlank(tpContactMap.get(tpId).Email)){
                continue;
            }

            for (Id tpIdII: tpContactMap.keySet()) {
                String toyokeizaiId_cII = tpContactMap.get(tpIdII).ToyokeizaiId__c;
                // 東洋経済IDのクレンジング(null -> '', trim)
                if (toyokeizaiId_cII == null) {
                    toyokeizaiId_cII = '';
                } else {
                    toyokeizaiId_cII = toyokeizaiId_cII.trim();
                }
                // 東洋経済IDが同一かつメールアドレス設定なしデータのメールアドレスを上書き
                if (String.isBlank(tpContactMap.get(tpIdII).Email) && (toyokeizaiId_c == toyokeizaiId_cII) && String.isNotBlank(toyokeizaiId_c + toyokeizaiId_cII) && String.isNotBlank(tpContactMap.get(tpId).Email)) {
                    Contact tpContact = tpContactMap.get(tpIdII);
                    tpContact.Email = tpContactMap.get(tpId).Email;
                    tpContactMap.put(tpIdII, tpContact);
                    break;
                }
            }
        }
        return tpContactMap;
    }

    /**
     * lastmodifieddateが最新であるレコード以外のレコードの「えびす退会日」「えびす削除日」をNULLに設定する
     */
    private Map < Id, Contact > setNullEbisuTaikaiDate(Map < Id, Contact > tpContactMap) {
        for (Id tpId: tpContactMap.keySet()) {
            Datetime tptmodifieddate = tpContactMap.get(tpId).lastmodifieddate;
            String emailAddress = tpContactMap.get(tpId).Email;

            String ToyokeizaiId_c = '';
            if (String.isNotBlank(tpContactMap.get(tpId).ToyokeizaiId__c)) {
                ToyokeizaiId_c = tpContactMap.get(tpId).ToyokeizaiId__c;
            }
            //System.debug(LoggingLevel.ERROR, '#M600__：\n①__:' + tpContactMap + '\n②__:' + emailAddress + '\n③__:' + ToyokeizaiId_c + '\n④__:' + tptmodifieddate + '\n⑤__:' +  + '\n⑥__:' +88);
            for (Id tpIdII: tpContactMap.keySet()) {
                String ToyokeizaiId_cII = '';
                if (String.isNotBlank(tpContactMap.get(tpIdII).ToyokeizaiId__c)) {
                    ToyokeizaiId_cII = tpContactMap.get(tpIdII).ToyokeizaiId__c;
                }
                //System.debug(LoggingLevel.ERROR, '#M601__：\n①__:' + emailAddress+'----'+tpContactMap.get(tpIdII).Email + '\n②__:' + ToyokeizaiId_c + '\n③__:' + tpContactMap + '\n④__:' + String.isNotBlank(ToyokeizaiId_c + ToyokeizaiId_cII) + '\n⑤__:' +  + '\n⑥__:' +88);
                // 東洋経済IDが設定かつ相違し、Emailが同一である古いデータのえびす退会日・えびす削除日をnullで更新
                if (
                    tptmodifieddate > tpContactMap.get(tpIdII).lastmodifieddate &&
                    emailAddress == tpContactMap.get(tpIdII).Email &&
                    String.isNotBlank(ToyokeizaiId_c) &&
                    String.isNotBlank(ToyokeizaiId_cII) &&
                    ToyokeizaiId_c != ToyokeizaiId_cII
                ) {
                    //System.debug(LoggingLevel.ERROR, '#M602__：\n①__:' + emailAddress+'----'+tpContactMap.get(tpIdII).Email + '\n②__:' + ToyokeizaiId_c + '\n③__:' + tpContactMap + '\n④__:' + String.isNotBlank(ToyokeizaiId_c + ToyokeizaiId_cII) + '\n⑤__:' +  + '\n⑥__:' +88);
                    Contact tpContact = tpContactMap.get(tpIdII);
                    tpContact.EbisuTaikaiDate__c = null;
                    tpContact.EbisuDelDate__c = null;
                    tpContactMap.put(tpIdII, tpContact);
                }
            }
        }
        return tpContactMap;
    }

    /**
     * 取引先責任者をキャンペーンに設定
     */
    private void assignCampaignMember(List<Contact> contacts) {
        System.debug(LoggingLevel.ERROR, '#M992__：' + contacts);

        Set<Id> campaignIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        // キャンペーンIDを持つレコードのID, キャンペーンIDを収集
        for (Contact contact : contacts) {
            if (contact.campaignId__c != null) {
                contactIds.add(contact.Id);
                campaignIds.add(contact.campaignId__c);
            }
        }

        // キャンペーン一覧の取得
        Map<Id, Campaign> campaigns = new Map<Id, Campaign>([select Id FROM Campaign where Id in :campaignIds]);

        // すでにキャンペーンメンバである場合スキップ
        Map<Id, Set<Id>> existsContactId2campaignIds = new Map<Id, Set<Id>>();

        List<CampaignMember> campaignMembers =
            [select Id, CampaignId, ContactId FROM CampaignMember where CampaignId in :campaignIds and ContactId in :contactIds];

        for (CampaignMember campaignMember : campaignMembers) {
            Set<Id> target = null;
            if (existsContactId2campaignIds.get(campaignMember.ContactId) == null) {
                target = new Set<Id>();
                existsContactId2campaignIds.put(campaignMember.ContactId, target);
            } else {
                target = existsContactId2campaignIds.get(campaignMember.ContactId);
            }

            target.add(campaignMember.CampaignId);
        }

        List<CampaignMember> membersToInsert = new List<CampaignMember>();
        List<Contact> contactsToUpdate = new List<Contact>();

        for (Contact contact : contacts) {
            Id campaignId = contact.campaignId__c;
            Contact updateContact = contact.clone(true, true);
            updateContact.campaignId__c = null;
            contactsToUpdate.add(updateContact);

            if (
                campaignId != null &&
                campaigns.get(campaignId) != null &&
                (
                    existsContactId2campaignIds.get(contact.Id) == null ||
                    ! existsContactId2campaignIds.get(contact.Id).contains(campaignId)
                )
            ) {
                CampaignMember member = new CampaignMember();
                member.ContactId = contact.Id;
                member.CampaignId = campaignId;
                membersToInsert.add(member);
            }
        }

        System.debug(LoggingLevel.ERROR, '#M993__：' + membersToInsert);

        insert membersToInsert;
        ContactMergeHandler.isTriggerCalled = false;
        update contactsToUpdate;
    }

}