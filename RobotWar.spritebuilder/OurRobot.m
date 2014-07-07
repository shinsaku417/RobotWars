//
//  OurRobot.m
//  RobotWar
//
//  Created by Masa and Shin on 6/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "OurRobot.h"
#import "Bullet.h"

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateTurnaround,
    RobotStateFiring,
    RobotStateSearching
};

@implementation OurRobot {
    RobotState _currentRobotState;
    
    CGPoint _hitPosition;
    CGRect _rect;
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
    int _count;
    BOOL _randomShoot;
    BOOL _p1;
    BOOL _p2;
    BOOL _hitting;
    int _turned;
    int _currentAngle;
    CGFloat _lastHitTimestamp;
    CGFloat _angle;
}

- (void)run {
    _currentAngle = 0;
    _turned = 0;
    _randomShoot = true;
    _p1 = false;
    _p2 = false;
    _hitting = false;
    [self moveBack:25];
    if (self.headingDirection.x >= 0.f) {
        _p1 = true;
        [self turnRobotRight:90];
        [self moveBack:75];
        [self turnGunLeft:55];
        _currentAngle += 55;
        //[self shoot];
    } else {
        _p2 = true;
        [self turnRobotRight:90];
        [self moveBack:75];
        [self turnGunLeft:55];
        _currentAngle += 55;
        [self shoot];
    }
    while (true) {
        if (_currentRobotState == RobotStateFiring) {
            if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
                _currentRobotState = RobotStateSearching;
            } else {
                CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
                if (angle >= 0) {
                    [self turnGunRight:abs(angle)];
                    [self shoot];
                    [self turnGunRight:abs(angle)];
                    //_currentAngle -= abs(angle);
                } else {
                    [self turnGunLeft:abs(angle)];
                    [self shoot];
                    [self turnGunLeft:abs(angle)];
                    //_currentAngle += abs(angle);
                }
            }
        }
        if (_hitting)  {
            _angle = (atan2f((_rect.origin.y + _rect.size.height/2) - _hitPosition.y, _hitPosition.x - (_rect.origin.x + _rect.size.width))) * 180 /M_PI;
            //NSLog(@"%f", _currentAngle - (90 - _angle));
            [self turnGunRight:(_currentAngle - (90 - _angle))];
            _currentAngle -= _currentAngle - (90 - _angle);
            [self shoot];
        }
        if ((self.currentTimestamp - _lastHitTimestamp) > 2.f) {
            _hitting = FALSE;
        }
        if (_hitting == FALSE) {
            _currentRobotState = RobotStateSearching;
            
            if (_currentRobotState == RobotStateSearching) {
                //[self turnGunLeft:(_turned)];
                //_turned = 0;
                _currentRobotState = RobotStateDefault;
            }
            
            if (_currentRobotState == RobotStateDefault) {
                //if (_p1) {
                    if (_randomShoot) {
                        [self shoot];
                        [self turnGunLeft:10];
                        _currentAngle += 10;
                    }
                    else {
                        [self shoot];
                        [self turnGunRight:10];
                        _currentAngle -= 10;
                    }
                    if (_currentAngle >= 90 || _currentAngle <= 0) {
                        _count = 0;
                        _randomShoot = !_randomShoot;
                    }
//                } else {
//                    if (_randomShoot) {
//                        [self shoot];
//                        [self turnGunLeft:10];
//                        _count++;
//                    }
//                    else {
//                        [self shoot];
//                        [self turnGunRight:10];
//                        _count++;
//                    }
//                    if (_currentAngle >= 90) {
//                        _count = 0;
//                        _randomShoot = !_randomShoot;
//                    }
//                    
//                }
            
            }
            
        }
        
    }
}

- (void)bulletHitEnemy:(Bullet *)bullet {
    // There are a couple of neat things you could do in this handler
    _hitPosition = bullet.position;
    _rect = [self robotBoundingBox];
    _hitting = TRUE;
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

//- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
//    if (_currentRobotState != RobotStateTurnaround) {
//        [self cancelActiveAction];
//
//        RobotState previousState = _currentRobotState;
//        _currentRobotState = RobotStateTurnaround;
//
//        // always turn to head straight away from the wall
//        if (angle >= 0) {
//            [self turnRobotLeft:abs(angle)];
//        } else {
//            [self turnRobotRight:abs(angle)];
//
//        }
//
//        [self moveAhead:20];
//
//        _currentRobotState = previousState;
//    }
//}

@end

