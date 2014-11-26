//
//  MosquittoCallbackBridge.m
//  Moscapsule
//
//  Created by flightonary on 2014/11/25.
//
//    The MIT License (MIT)
//
//    Copyright (c) 2014 tonary <jetBeaver@gmail.com>. All rights reserved.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of
//    this software and associated documentation files (the "Software"), to deal in
//    the Software without restriction, including without limitation the rights to
//    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//    the Software, and to permit persons to whom the Software is furnished to do so,
//    subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import "MosquittoCallbackBridge.h"
#import "mosquitto.h"
#import "Moscapsule/Moscapsule-Swift.h"

@implementation MosquittoContext : NSObject
@end

// , void (^onConnect)(int returnCode), void (^onDisconnect)(int reasonCode)
MosquittoContext *mosquitto_context_new(const char *clientId, bool cleanSession)
{
    MosquittoContext *mosquittoContext = [[MosquittoContext alloc] init];
    if (!mosquittoContext) {
        return nil;
    }

    struct mosquitto *mosquittoHandler = mosquitto_new(clientId, cleanSession, (__bridge void*)mosquittoContext);
    if (!mosquittoHandler) {
        return nil;
    }

    mosquittoContext.mosquittoHandler = mosquittoHandler;
    mosquittoContext.isConnected = false;
    mosquittoContext.onConnectCallback = nil;
    mosquittoContext.onDisconnectCallback = nil;
    mosquittoContext.onPublishCallback = nil;
    mosquittoContext.onMessageCallback = nil;
    mosquittoContext.onSubscribeCallback = nil;
    mosquittoContext.onUnsubscribeCallback = nil;
    setMosquittoCallbackBridge(mosquittoContext.mosquittoHandler);

    return mosquittoContext;
}

void mosquitto_context_destroy(MosquittoContext *mosquittoContext)
{
    mosquitto_destroy(mosquittoContext.mosquittoHandler);
}

static void setMosquittoCallbackBridge(struct mosquitto *mosquittoHandler)
{
    mosquitto_connect_callback_set(mosquittoHandler, on_connect);
    mosquitto_disconnect_callback_set(mosquittoHandler, on_disconnect);
    mosquitto_publish_callback_set(mosquittoHandler, on_publish);
    mosquitto_message_callback_set(mosquittoHandler, on_message);
    mosquitto_subscribe_callback_set(mosquittoHandler, on_subscribe);
    mosquitto_unsubscribe_callback_set(mosquittoHandler, on_unsubscribe);
#ifdef DEBUG
    mosquitto_log_callback_set(mosquittoHandler, on_log);
#endif
}

static void on_connect(struct mosquitto *mosquittoHandler, void *obj, int returnCode)
{
    MosquittoContext *mosquittoContext = (__bridge MosquittoContext*)obj;
    if (mosquittoContext.onConnectCallback) {
        mosquittoContext.onConnectCallback(returnCode);
    }
}

static void on_disconnect(struct mosquitto *mosquittoHandler, void *obj, int reasonCode)
{
    MosquittoContext* mosquittoContext = (__bridge MosquittoContext*)obj;
    if (mosquittoContext.onDisconnectCallback) {
        mosquittoContext.onDisconnectCallback(reasonCode);
    }
}

static void on_publish(struct mosquitto *mosquittoHandler, void *obj, int messageId)
{
    
}

static void on_message(struct mosquitto *mosquittoHandler, void *obj, const struct mosquitto_message *message)
{
    
}

static void on_subscribe(struct mosquitto *mosquittoHandler, void *obj, int messageId, int qos_count, const int *granted_qos)
{
    
}

static void on_unsubscribe(struct mosquitto *mosquittoHandler, void *obj, int messageId)
{
    
}

static void on_log(struct mosquitto *mosquittoHandler, void *obj, int logLevel, const char *logMessage)
{
    NSLog(@"[MOSQUITTO] %s %s", LogLevelString(logLevel), logMessage);
}

static const char *LogLevelString(int logLevel)
{
    switch (logLevel) {
        case MOSQ_LOG_INFO:
            return "INFO   ";
        case MOSQ_LOG_NOTICE:
            return "NOTICE ";
        case MOSQ_LOG_WARNING:
            return "WARNING";
        case MOSQ_LOG_ERR:
            return "ERROR  ";
        case MOSQ_LOG_DEBUG:
            return "DEBUG  ";
        default:
            break;
    }
    return "       ";
}
