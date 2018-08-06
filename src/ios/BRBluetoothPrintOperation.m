//
//  BRBluetoothPrintOperation.m
//  SDK_Sample_Ver2
//
//  Created by Kusumoto Naoki on 2015/08/18.
//  Copyright (c) 2015年 Kusumoto Naoki. All rights reserved.
//

#import "BRUserDefaults.h"
#import "BRBluetoothPrintOperation.h"

@interface BRBluetoothPrintOperation () {
}
@property(nonatomic, assign) BOOL isExecutingForBT;
@property(nonatomic, assign) BOOL isFinishedForBT;

@property(nonatomic, weak) BRPtouchPrinter    *ptp;
@property(nonatomic, strong) BRPtouchPrintInfo  *printInfo;
@property(nonatomic, assign) CGImageRef         imgRef;
@property(nonatomic, assign) int                numberOfPaper;
@property(nonatomic, strong) NSString           *serialNumber;

@end


@implementation BRBluetoothPrintOperation

@synthesize resultStatus = _resultStatus;
@synthesize errorCode = _errorCode;
@synthesize dict = _dict;

-(id)initWithOperation:(BRPtouchPrinter *)targetPtp
             printInfo:(BRPtouchPrintInfo *)targetPrintInfo
                imgRef:(CGImageRef)targetImgRef
         numberOfPaper:(int)targetNumberOfPaper
          serialNumber:(NSString *)targetSerialNumber
              withDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.ptp            = targetPtp;
        self.printInfo      = targetPrintInfo;
        self.imgRef         = targetImgRef;
        self.numberOfPaper  = targetNumberOfPaper;
        self.serialNumber   = targetSerialNumber;
        _dict               = dict;
    }

    return self;
}

+(BOOL)automaticallyNotifiesObserversForKey:(NSString*)key {
    if (
        [key isEqualToString:@"communicationResultForBT"]   ||
        [key isEqualToString:@"isExecutingForBT"]           ||
        [key isEqualToString:@"isFinishedForBT"]) {
        return YES;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

-(void)main {
    self.isExecutingForBT = YES;

    [self.ptp setupForBluetoothDeviceWithSerialNumber:self.serialNumber];

    if ([self.ptp isPrinterReady]) {
        self.communicationResultForBT = [self.ptp startCommunication];
        if (self.communicationResultForBT) {
            [self.ptp setPrintInfo:self.printInfo];

            //[self.commandDelegate runInBackground:^{
            
            BRPtouchPrinterStatus *status;
            //_errorCode = [self.ptp getStatus:&status];
            _errorCode = [self.ptp printImage:self.imgRef copy:self.numberOfPaper];
            if (_errorCode != 0) {
                [self.ptp cancelPrinting];
            }
            /*PTSTATUSINFO resultstatus;
            [self.ptp getPTStatus:&resultstatus];
            _resultStatus = resultstatus;*/
        }

        [self.ptp endCommunication];

    } else {
        self.communicationResultForBT = NO;
    }

    self.isExecutingForBT = NO;
    self.isFinishedForBT = YES;
}

@end
