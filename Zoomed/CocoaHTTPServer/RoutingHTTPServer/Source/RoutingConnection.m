#import "RoutingConnection.h"
#import "RoutingHTTPServer.h"
#import "HTTPMessage.h"
#import "HTTPResponseProxy.h"

@implementation RoutingConnection {
	__unsafe_unretained RoutingHTTPServer *http;
	NSDictionary *headers;
}

- (id)initWithAsyncSocket:(GCDAsyncSocket *)newSocket configuration:(HTTPConfig *)aConfig {
	if (self = [super initWithAsyncSocket:newSocket configuration:aConfig]) {
		NSAssert([config.server isKindOfClass:[RoutingHTTPServer class]],
				 @"A RoutingConnection is being used with a server that is not a RoutingHTTPServer");

		http = (RoutingHTTPServer *)config.server;
	}
	return self;
}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {

	if ([http supportsMethod:method])
		return YES;

	return [super supportsMethod:method atPath:path];
}

- (BOOL)shouldHandleRequestForMethod:(NSString *)method atPath:(NSString *)path {
	// The default implementation is strict about the use of Content-Length. Either
	// a given method + path combination must *always* include data or *never*
	// include data. The routing connection is lenient, a POST that sometimes does
	// not include data or a GET that sometimes does is fine. It is up to the route
	// implementations to decide how to handle these situations.
	return YES;
}

- (void)processBodyData:(NSData *)postDataChunk {
	BOOL result = [request appendData:postDataChunk];
	if (!result) {
		// TODO: Log
	}
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
	NSURL *url = [request url];
	NSString *query = nil;
	NSDictionary *params = [NSDictionary dictionary];
	headers = nil;

	if (url) {
		path = [url path]; // Strip the query string from the path
		query = [url query];
		if (query) {
			params = [self parseParams:query];
		}
	}

	RouteResponse *response = [http routeMethod:method withPath:path parameters:params request:request connection:self];
	if (response != nil) {
		headers = response.headers;
		return response.proxiedResponse;
	}

	// Set a MIME type for static files if possible
	NSObject<HTTPResponse> *staticResponse = [super httpResponseForMethod:method URI:path];
	if (staticResponse && [staticResponse respondsToSelector:@selector(filePath)]) {
		NSString *mimeType = [http mimeTypeForPath:[staticResponse performSelector:@selector(filePath)]];
		if (mimeType) {
			headers = [NSDictionary dictionaryWithObject:mimeType forKey:@"Content-Type"];
		}
	}
	return staticResponse;
}

- (void)responseHasAvailableData:(NSObject<HTTPResponse> *)sender {
	HTTPResponseProxy *proxy = (HTTPResponseProxy *)httpResponse;
	if (proxy.response == sender) {
		[super responseHasAvailableData:httpResponse];
	}
}

- (void)responseDidAbort:(NSObject<HTTPResponse> *)sender {
	HTTPResponseProxy *proxy = (HTTPResponseProxy *)httpResponse;
	if (proxy.response == sender) {
		[super responseDidAbort:httpResponse];
	}
}

- (void)setHeadersForResponse:(HTTPMessage *)response isError:(BOOL)isError {
	[http.defaultHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL *stop) {
		[response setHeaderField:field value:value];
	}];

	if (headers && !isError) {
		[headers enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL *stop) {
			[response setHeaderField:field value:value];
		}];
	}

	// Set the connection header if not already specified
	NSString *connection = [response headerField:@"Connection"];
	if (!connection) {
		connection = [self shouldDie] ? @"close" : @"keep-alive";
		[response setHeaderField:@"Connection" value:connection];
	}
}

- (NSData *)preprocessResponse:(HTTPMessage *)response {
	[self setHeadersForResponse:response isError:NO];
	return [super preprocessResponse:response];
}

- (NSData *)preprocessErrorResponse:(HTTPMessage *)response {
	[self setHeadersForResponse:response isError:YES];
	return [super preprocessErrorResponse:response];
}

- (BOOL)shouldDie {
	__block BOOL shouldDie = [super shouldDie];

	// Allow custom headers to determine if the connection should be closed
	if (!shouldDie && headers) {
		[headers enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL *stop) {
			if ([field caseInsensitiveCompare:@"connection"] == NSOrderedSame) {
				if ([value caseInsensitiveCompare:@"close"] == NSOrderedSame) {
					shouldDie = YES;
				}
				*stop = YES;
			}
		}];
	}

	return shouldDie;
}

- (BOOL)isSecureServer
{

    // Create an HTTPS server (all connections will be secured via SSL/TLS)
    return YES;
}

/**
 * This method is expected to returns an array appropriate for use in kCFStreamSSLCertificates SSL Settings.
 * It should be an array of SecCertificateRefs except for the first element in the array, which is a SecIdentityRef.
 **/
- (NSArray *)sslIdentityAndCertificates
{
    SecIdentityRef identityRef = NULL;
    SecCertificateRef certificateRef = NULL;
    SecTrustRef trustRef = NULL;

    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"1chuidingyin.com" ofType:@"p12"];
    NSData *PKCS12Data = [[NSData alloc] initWithContentsOfFile:thePath];
    CFDataRef inPKCS12Data = (CFDataRef)CFBridgingRetain(PKCS12Data);
    CFStringRef password = CFSTR("123456");
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = {password};//password
    CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);

    OSStatus securityError = errSecSuccess;
    securityError =  SecPKCS12Import(inPKCS12Data, optionsDictionary, &items);
    if (securityError == 0) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemIdentity);
        identityRef = (SecIdentityRef)tempIdentity;
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemTrust);
        trustRef = (SecTrustRef)tempTrust;
    } else {
        NSLog(@"Failed with error code %d",(int)securityError);
        return nil;
    }

    SecIdentityCopyCertificate(identityRef, &certificateRef);
    NSArray *result = [[NSArray alloc] initWithObjects:(id)CFBridgingRelease(identityRef),   (id)CFBridgingRelease(certificateRef), nil];

    return result;
}

//- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
//{
//    // do something
//    return [super httpResponseForMethod:method URI:path];
//}

@end
