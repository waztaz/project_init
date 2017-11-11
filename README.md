### Getting Started

First you need an application id and secret so reddit knows your application. You get this information by going to https://www.reddit.com/prefs/apps and clicking "are you a developer? create an app..."

![App Information Screen](http://i.imgur.com/e2kOR1a.png)

When registering your app, it's important to choose the correct and relevant app "type," as the type determines what authentication paths your app may take. Read more on [app types](oauth2-app-types).

* Web app: Runs as part of a web service on a server you control. Can keep a secret.
* Installed app: Runs on devices you don't control, such as the user's mobile phone. *Cannot* keep a secret, and therefore, does not receive one.
* Script app: Runs on hardware you control, such as your own laptop or server. Can keep a secret. Only has access to your account.

Be sure to give the app a reasonable name and description. The redirect uri is important - for web apps, it points to a URL on a webserver that you control.

The part underlined in red is your client secret. *You should never share this.* Non-confidential clients (installed apps) *do not* have a secret.


### How to get the data

#### Store credentials
Once, you've gotten your credentials, create a file called `credentials.json` and store all the information in the following format
```
{
  "username" : "your_acccount_username",
  "password" : "your_account_password",
  "client_id" : "your_client_public_key",
  "client_secret" : "your_client_private key"
}
```

#### Install dependencies
We will now make sure, we have all the dependencies that we need. Ensure that you have bundler installed. Then execute:
```
bundle install
```

#### Execute script
The final step is actually execute the script that runs and fetches the data for you.
```
rake run
```
