//

//  OurOriginal.m

//  RobotWar

//

//  Created by Shinsaku Uesugi on 6/30/14.

//  Copyright (c) 2014 Apportable. All rights reserved.

//



#import "OurOriginal.h"



typedef NS_ENUM(NSInteger, RobotState) {
    
    RobotStateDefault,
    
    RobotStateTurnaround,
    
    RobotStateFiring,
    
    RobotStateSearching
    
};



@implementation OurOriginal {
    
    RobotState _currentRobotState;
    
    
    
    CGPoint _lastKnownPosition;
    
    CGFloat _lastKnownPositionTimestamp;
    
    int _count;
    
    BOOL _randomShoot;
    
    BOOL _p1;
    
    BOOL _p2;
    
    int _turned;
    
}



- (void)run {
    
    _count = 0;
    
    _turned = 0;
    
    _randomShoot = true;
    
    _p1 = false;
    
    _p2 = false;
    
    [self moveBack:45];
    
    if (self.headingDirection.x >= 0.f) {
        
        [self turnRobotRight:90];
        
        [self moveBack:93];
        
    } else {
        
        [self turnRobotRight:90];
        
        [self moveBack:93];
        
    }
    while (true) {}
    while (true) {
        
        if (_currentRobotState == RobotStateFiring) {
            
            NSLog(@"plz");
            
            
            
            if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
                
                _currentRobotState = RobotStateSearching;
                
            } else {
                
                CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
                
                if (angle >= 0) {
                    
                    [self turnGunRight:abs(angle)];
                    
                    _turned += angle;
                    
                } else {
                    
                    [self turnGunLeft:abs(angle)];
                    
                    _turned -= angle;
                    
                }
                
                [self shoot];
                
            }
            
        }
        
        
        
        if (_currentRobotState == RobotStateSearching) {
            
            [self turnGunLeft:(_turned)];
            
            _turned = 0;
            
            _currentRobotState = RobotStateDefault;
            
        }
        
        
        
        if (_currentRobotState == RobotStateDefault) {
            
            
            if (_randomShoot) {
                
                [self shoot];
                
                [self turnGunLeft:10];
                
                _count++;
                
            }
            
            else {
                
                [self shoot];
                
                [self turnGunRight:10];
                
                _count++;
                
            }
            
            if (_count == 9) {
                
                _count = 0;
                
                _randomShoot = !_randomShoot;
                
            }
            
            
            
        }
        
        
        
    }
    
}



- (void)bulletHitEnemy:(Bullet *)bullet {
    
    // There are a couple of neat things you could do in this handler
    
}



- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    
    if (_currentRobotState != RobotStateFiring) {
        
        [self cancelActiveAction];
        
    }
    
    
    
    _lastKnownPosition = position;
    
    _lastKnownPositionTimestamp = self.currentTimestamp;
    
    _currentRobotState = RobotStateFiring;
    
}


@end