@isTest
private class DeployTest {
    static testMethod void UnitTest() {
        Test.startTest();
        Deploy tpDeploy = new Deploy();
        tpDeploy.goThrowIn();
        Test.stopTest();
    }
}