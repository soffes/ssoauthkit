# SSOAuthKit

SSOAuthKit was designed to making interacting with OAuth 1.0 services as painless as possible. (If you are looking for an OAuth 2.0 client, check out [LROAuth2Client](http://github.com/lukeredpath/lroauth2client).)

## Configuration

Having include a header file with your consumer credentials is kind of a pain. Different applications manage their constants different. SSOAuthKit is flexible. You just have to call the following method once to setup your credentials.

```objective-c
[SSOAuthKitConfiguration setConsumerKey:@"CONSUMER_KEY_GOES_HERE" secret:@"CONSUMER_SECRET_GOES_HERE"];
```

Done. Simple as that.

## Making Requests

SSOAuthKit's core is `SSOARequest` and `SSOAFormRequest` which are subclasses of `ASIHTTPRequest`. You just simply set a token like this:

```objective-c
SSOARequest *request = [[SSOARequest alloc] initWithURL:someUrl];
request.token = yourToken;
[request startAsynchronous];
[request release];
```

## Twitter

The main goal of SSOAuthKit was to make authenticating with Twitter stupid easy. There is a handy class called `SSTwitterOAuthViewController` that handles *everything* for you. You can have your application setup on Twitter to do the pin style verification or the redirect style verification. (If you do the redirect style, the redirect is stopped and verified by the library. You are responsible for forwarding the message to your server.) Pin style is recommended. Just present it as a modal:

```objective-c
SSTwitterOAuthViewController *viewController = [[SSTwitterOAuthViewController alloc] initWithDelegate:self];
UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
[self presentModalViewController:navigationController animated:YES];
[viewController release];
[navigationController release];
```

You can of course, do it however you want though.

`SSTwitterAuthViewController` has three optional delegate methods:

```objective-c
- (void)twitterAuthViewControllerDidCancel:(UIViewController *)viewController;
- (void)twitterAuthViewController:(UIViewController *)viewController didFailWithError:(NSError *)error;
- (void)twitterAuthViewController:(UIViewController *)viewController didAuthorizeWithAccessToken:(SSOAToken *)accessToken userDictionary:(NSDictionary *)userDictionary;
```

So if something fails, you get an error that you can handle. If it succeeds, you got their access token and an NSDictionary of their user from Twitter.

### xAuth

Twitter's [xAuth](http://dev.twitter.com/pages/xauth) is also supported. To use, implement the same delegates and use the following code to present the modal:

```objective-c
SSTwitterXAuthViewController *viewController = [[SSTwitterXAuthViewController alloc] initWithDelegate:self];
UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
[self presentModalViewController:navigationController animated:YES];
[viewController release];
[navigationController release];
```

The [demo app](https://github.com/samsoffes/ssoauthkit/tree/master/TwitterDemo) has examples of both methods.

## Adding SSOAuthKit (and SSToolkit) to your project

SSOAuthKit depends on SSToolkit. Adding SSOAuthKit will add SSToolkit (as well as ASIHTTPRequest and yajl-objc) to your project.

1. Run the following command to add the submodule. Be sure you have been added to the project on GitHub.

        git submodule add --recursive git://github.com/samsoffes/ssoauthkit.git Frameworks/SSOAuthKit

2. In Finder, navigate to the `Frameworks/SSOAuthKit` folder and drag the `xcodeproj` file into the `Frameworks` folder in your Xcode project.

3. In Finder, drag `SSOAuthKit.bundle` located in `Frameworks/SSOAuthKit/Resources` into the `Resources` folder in your Xcode project.

4. In Finder, drag `SSToolkit.bundle` located in `Frameworks/SSOAuthKit/SSOAuthKit/Vendor/SSToolkit/Resources` into the `Resources` folder in your Xcode project.

5. Select the SSOAuthKit Xcode project from the sidebar in Xcode. In the file browser on the right in Xcode, click the checkbox next to `libSSOAuthKit.a`. (If you don't see the file browser, hit Command-Shift-E to toggle it on.)

6. Select your target from the sidebar and open Get Info (Command-I).

7. Choose the *General* tab from the top.

8. Under the *Direct Dependencies* area, click the plus button, select *SSOAuthKit* from the menu, and choose *Add Target*.

9. Choose the build tab from the top of the window. Make sure the configuration dropdown at the top is set to *All Configurations*.

9. Add `Frameworks/SSOAuthKit` to *Header Search Path* and click the *Recursive* checkbox.

10. Add `-all_load -ObjC` to *Other Linker Flags*.
