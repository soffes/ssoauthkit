# TWOAuthKit

TWOAuthKit was designed to making interacting with OAuth 1.0 services as painless as possible. (If you are looking for an OAuth 2.0 client, check out [LROAuth2Client](http://github.com/lukeredpath/lroauth2client).)

## Configuration

Having include a header file with your consumer credentials is kind of a pain. Different applications manage their constants different. TWOAuthKit is flexible. You just have to call the following method once to setup your credentials.

    [TWOAuthKitConfiguration setConsumerKey:@"CONSUMER_KEY_GOES_HERE" secret:@"CONSUMER_SECRET_GOES_HERE"];

Done. Simple as that.

## Making Requests

TWOAuthKit's core is `TWOARequest` and `TWOAFormRequest` which are subclasses of `ASIHTTPRequest`. You just simply set a token like this:

    TWOARequest *request = [[TWOARequest alloc] initWithURL:someUrl];
    request.token = yourToken;
    [request startAsynchronous];
    [request release];

## Twitter

The main goal of TWOAuthKit was to make authenticating with Twitter stupid easy. There is a handy class called `TWTwitterOAuthViewController` that handles *everything* for you. Just present it as a modal:

    TWTwitterOAuthViewController *viewController = [[TWTwitterOAuthViewController alloc] initWithDelegate:self];
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:viewController animated:YES];
    [viewController release];

You can of course, do it however you want though.

`TWTwitterOAuthViewController` has three delegate methods:

    - (void)twitterOAuthViewControllerDidCancel:(TWTwitterOAuthViewController *)viewController;
    - (void)twitterOAuthViewController:(TWTwitterOAuthViewController *)viewController didFailWithError:(NSError *)error;
    - (void)twitterOAuthViewController:(TWTwitterOAuthViewController *)viewController didAuthorizeWithAccessToken:(TWOAToken *)accessToken userDictionary:(NSDictionary *)userDictionary;

So if something fails, you get an error that you can handle. If it succeeds, you got their access token and an NSDictionary of their user from Twitter.
