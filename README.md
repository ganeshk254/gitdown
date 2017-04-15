# gitdown
Clone all the repositories the user contributed to or repos from the orgs the user is part of.
This includes the user personal repositories and the organizations repositories.


## Usage
  Simply clone the repository/download the `gitdown.rb` file.

### Generate your personal access token
  * You can create your personal access token at https://github.com/settings/tokens
  * Remember to note the token down as GitHub will not show it again.
  * The personal access token page for GitHub Enterprise Edition is `<EnterpriseURL>/settings/tokens`

### Command
```bash
ruby gitdown.rb -t <token> -e <endpoint>
```

***Examples*** -
  * If you want to clone from github.com, you can simply use
    ```bash
    ruby gitdown.rb -t youraccesstokenhere
    ```
  * If you are using GitHub Enterprise Edition, you can use
    ```bash
    ruby gitdown.rb -t youraccesstokenhere -e https://github.acme.com/api/v3
    ```
