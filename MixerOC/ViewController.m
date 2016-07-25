//
//  ViewController.m
//  混音OC
//
//  Created by Bruce on 16/7/25.
//  Copyright © 2016年 Bruce. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (nonnull, nonatomic, strong) AVAudioEngine *engine;
@property (nonnull, nonatomic, strong) AVAudioMixerNode *mixer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    输入
    AVAudioInputNode *input = self.engine.inputNode;
    //    输出
    AVAudioOutputNode *output = self.engine.outputNode;
    
    //    音效
    AVAudioUnitDelay *delay = [[AVAudioUnitDelay alloc] init];
    delay.wetDryMix = 30;
    delay.feedback = 30;
    delay.delayTime = 0.3;
    [self.engine attachNode:delay];
    
    //    混音
    [self.engine attachNode:self.mixer];
    
    //    要写入到的文件
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    path = [path stringByAppendingPathComponent:@"finish.aiff"];
    
    __block NSError *error;
    AVAudioFile *audioFile = [[AVAudioFile alloc] initForWriting:[NSURL fileURLWithPath:path] settings:@{} error:&error];
    [self.mixer installTapOnBus:0 bufferSize:8192 format:[input inputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [audioFile writeFromBuffer:buffer error:&error];
    }];
    
    [self.engine connect:input to:delay format:[input inputFormatForBus:0]];
    [self.engine connect:delay to:self.mixer format:[input inputFormatForBus:0]];
    [self.engine connect:self.mixer to:output format:[input inputFormatForBus:0]];
}

- (void)start {
    NSError *error;
    [self.engine startAndReturnError:&error];
}

- (void)stop {
    [self.mixer removeTapOnBus:0];
    [self.engine stop];
}

- (IBAction)control:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    sender.selected == YES ? [self start]:[self stop];
}


- (AVAudioEngine *)engine{
    if (!_engine) {
        _engine = [[AVAudioEngine alloc] init];
    }
    return _engine;
}

- (AVAudioMixerNode *)mixer{
    if (!_mixer) {
        _mixer = [[AVAudioMixerNode alloc] init];
    }
    return _mixer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
