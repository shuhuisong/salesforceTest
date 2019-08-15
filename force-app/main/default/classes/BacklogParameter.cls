public with sharing class BacklogParameter {
    public Project project;
    public Content content;

    public class Project{
        public String id;
        public String projectKey;
        public String name;
    }

    public class Content{
        public String id;
        public String summary; // 件名 = タイトル
        public String description; // 詳細
        public IssueType issueType; // タスク
        public Status status; // 状態
        public List<Category> category; // カテゴリー
        public String startDate; // 開始日
        public String dueDate; // 期限日
        public List<customFields> customFields; //カスタム属性
    }

    public class IssueType{
        public String id;
        public String name; // 種別
    }

    public class Status{
        public String id;
        public String name; // 状態
    }

    public class Category{
        public String id;
        public String name; // カテゴリー
    }

    public class customFields{
        public String field;
        public String value;
    }
}