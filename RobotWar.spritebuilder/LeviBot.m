//
//  AdvancedRobot.m
//  RobotWar
//
//  Created by Benjamin Encz on 03/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "LeviBot.h"

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateTurnaround,
    RobotStateFiring,
    RobotStateSearching
};

@implementation LeviBot {
    RobotState _currentRobotState;
    
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
    CGFloat _lastHitTimestamp;
    
    BOOL _leviMode;
}

- (void)run {
    _leviMode = false;
    while (true) {
        if (_currentRobotState == RobotStateFiring) {
            
            if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
                _currentRobotState = RobotStateSearching;
            } else {
                CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
                if (angle >= 0) {
                    [self turnGunRight:abs(angle)];
                } else {
                    [self turnGunLeft:abs(angle)];
                }
                [self shoot];
            }
        }
        
        if (_currentRobotState == RobotStateSearching) {
            if (self.currentTimestamp - _lastHitTimestamp > 5) {
                _leviMode = true;
            }
            if (_leviMode) {
                [self shoot];
                [self turnRobotLeft:5];
                [self shoot];
                [self turnRobotLeft:5];
                [self shoot];
                [self turnRobotLeft:5];
                [self shoot];
                [self turnRobotLeft:5];
                [self shoot];
                [self turnRobotRight:20];
                [self shoot];
                
                [self turnRobotRight:5];
                [self shoot];
                [self turnRobotRight:5];
                [self shoot];
                [self turnRobotRight:5];
                [self shoot];
                [self turnRobotRight:5];
                [self shoot];
                [self turnRobotRight:5];
                [self shoot];
                [self turnRobotRight:5];
                [self shoot];
                [self turnRobotRight:5];
                [self shoot];
                [self turnRobotRight:5];
                [self shoot];
                
                [self turnRobotLeft:40];
                
            } else {
                [self turnGunRight:20];
                [self shoot];
                [self turnGunLeft: 30];
                [self shoot];
                [self turnGunRight:10];
            }
            
        }
        
        if (_currentRobotState == RobotStateDefault) {
            _currentRobotState = RobotStateSearching;
        }
    }
}

- (void)bulletHitEnemy:(Bullet *)bullet {
    _lastHitTimestamp = self.currentTimestamp;
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    if (_currentRobotState != RobotStateFiring) {
        [self cancelActiveAction];
    }
    
    _lastKnownPosition = position;
    _lastKnownPositionTimestamp = self.currentTimestamp;
    _currentRobotState = RobotStateFiring;
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
    if (_currentRobotState != RobotStateTurnaround) {
        [self cancelActiveAction];
        
        RobotState previousState = _currentRobotState;
        _currentRobotState = RobotStateTurnaround;
        
        // always turn to head straight away from the wall
        if (angle >= 0) {
            [self turnRobotLeft:abs(angle)];
        } else {
            [self turnRobotRight:abs(angle)];
            
        }
        
        [self moveAhead:20];
        
        _currentRobotState = previousState;
    }
}

@end
