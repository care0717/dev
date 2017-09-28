# Sprint Data Creator
## これは何？
スプリント期間中にチームが行ったことのデータを、GitHubからとるためのツールです。

## 環境セットアップ
Octokitを使っているので、以下のコマンドを打ってインストールしてください。
```
bundle install
```
環境変数にGitHubへのアクセストークンを設定してください。
```
export SDC_ACCESS_TOKEN=your_access_token
```

条件設定のためのファイル(condition.json)の設定が必要です。

#### 一例
```
{
    "repository": [
      "opt-tech/v7-apps",
      "opt-tech/v7-docs"
    ],
    "lightningTeam": [
        "sisisin",
        "tokiyaa"
    ]
}
```
repositoryにはデータを抽出するrepositoryを  
lightningTeamにはチームの*GitHubのLoginName*を設定してください。  
※mainと同じディレクトリに入れてください。
## 実行
```
ruby main.rb スプリント開始日 スプリント終了日 出力フォーマット
```
### 例
```
ruby main.rb 2017-8-22 2017-9-5 csv
```
出力フォーマットは今の所　"csv", "tsv", 何もなし　のいすれかです。  
開始日の0時から終了日の0時まで取ってきます。


