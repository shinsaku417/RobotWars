//
//  Kamikaze.m
//  RobotWar
//
//  Created by Masa and Shin on 6/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//
// Bugs vs DemiPixel (when p2)

#import "ShingekiNoKyojin8.h"
#import "Bullet.h"

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateTurnaround,
    RobotStateFiring,
};

@implementation ShingekiNoKyojin8 {
    RobotState _currentRobotState;
    
    int _ourHP;
    int _theirHP;
    
    CGPoint _hitPosition;
    CGRect _rect;
    CGRect _startRect;
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
    BOOL _randomShoot;
    BOOL _shootLeft;
    BOOL _shootRight;
    BOOL _p1;
    BOOL _p2;
    BOOL _hitting;
    double _currentAngle;
    CGFloat _lastHitTimestamp;
    CGFloat _angle;
    BOOL _atTop;
    int _random;
    int emergency;
    BOOL _notMoving;
}

- (void)run {
    emergency = 0;
    _notMoving = true;
    _random = (arc4random() % 2) + 1;
    //_random = 1;
    _atTop = true;
    _ourHP = 20;
    _theirHP = 20;
    _startRect = [self robotBoundingBox];
    
    // our starting position
    if (_startRect.origin.x < 284) {
        _p1 = true;
    } else {
        _p2 = true;
    }
    
    // whether our bullet hits enemy or not
    _hitting = false;
    
    if (_random == 1) {
        [self moveBack:50];
        _currentAngle = 0;
        [self turnRobotRight:90];
        [self moveBack:75];
        _shootLeft = true;
        if (_p2) {
            _atTop = false;
        }
    } else {
        // step 1: Move to the corner
        [self moveBack:50];
        _currentAngle = 90;
        [self turnRobotRight:90];
        [self moveAhead:200];
        [self turnGunLeft:180];
        _shootLeft = false;
        if (_p1) {
            _atTop = false;
        }
    }
    /*
     
     
     
     _currentAngle = 80;
     _atTop = !_atTop;
     _shootLeft = true;
     */
    while (true) {
        // Search first
        if (_currentRobotState == RobotStateFiring) {
            NSLog(@"Searching");
            if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
                _currentRobotState = RobotStateDefault;
            } else {
                CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
                if (angle >= 0) {
                    [self turnGunRight:abs(angle)];
                    [self shoot];
                    _currentAngle -= abs(angle);
                    
                } else {
                    [self turnGunLeft:abs(angle)];
                    [self shoot];
                    _currentAngle += abs(angle);
                    
                }
            }
        }
        // If the bullet hits enemy, bulletHitEnemy method runs => read comment for that method first
        else {
            if (_hitting && emergency != 1) {
                if (_p1 && _atTop) {
                    _angle = (atan2f((_rect.origin.y + _rect.size.height/2) - _hitPosition.y, _hitPosition.x - (_rect.origin.x + _rect.size.width/2))) * 180 /M_PI;
                    [self turnGunRight:(_currentAngle - (90 - (int)(_angle + 0.5)))];
                    _currentAngle -= _currentAngle - (90 - (int)(_angle + 0.5));
                    [self shoot];
                }
                if (_p2 && !_atTop) {
                    _angle = (atan2f(_hitPosition.y - (_rect.origin.y + _rect.size.height/2), (_rect.origin.x + _rect.size.width/2)- _hitPosition.x)) * 180 /M_PI;
                    [self turnGunRight:(_currentAngle - (90 - (int)(_angle + 0.5)))];
                    _currentAngle -= _currentAngle - (90 - (int)(_angle + 0.5));
                    [self shoot];
                }
                if (_p1 && !_atTop) {
                    _angle = (atan2f(_hitPosition.y - (_rect.origin.y + _rect.size.height/2), _hitPosition.x - (_rect.origin.x + _rect.size.width/2))) * 180 /M_PI;
                    [self turnGunLeft:(int)(_angle + 0.5) - _currentAngle];
                    _currentAngle += ((int)(_angle + 0.5) - _currentAngle);
                    [self shoot];
                }
                if (_p2 && _atTop) {
                    _angle = (atan2f((_rect.origin.y + _rect.size.height/2) - _hitPosition.y, (_rect.origin.x + _rect.size.width/2) - _hitPosition.x)) * 180 /M_PI;
                    [self turnGunLeft:(int)(_angle + 0.5) - _currentAngle];
                    _currentAngle += ((int)(_angle + 0.5) - _currentAngle);
                    [self shoot];
                }
                if ((self.currentTimestamp - _lastHitTimestamp) > 3.f) {
                    _hitting = false;
                }
            } else if (emergency == 1) {
                _currentRobotState = RobotStateDefault;
                _hitting = false;
            }
            else if (_currentRobotState == RobotStateDefault) {
                _notMoving = true;
                if (_shootLeft) {
                    [self shoot];
                    [self turnGunLeft:10];
                    _currentAngle += 10;
                }
                // If false, rotate to the right
                else {
                    [self shoot];
                    [self turnGunRight:10];
                    _currentAngle -= 10;
                }
                if (_currentAngle >= 90)
                {
                    _shootLeft = false;
                    //_shootRight = true;
                }
                if (_currentAngle <= 0-(90*emergency)) {
                    _shootLeft = true;
                    //_shootRight = false;
                }
                
            }
        }
    }
}

- (void)bulletHitEnemy:(Bullet *)bullet {
    // There are a couple of neat things you could do in this handler
    // First, get opponent's position
    _hitPosition = bullet.position;
    
    // Get my position too
    _rect = [self robotBoundingBox];
    
    // Set BOOL value to true since bullet is hitting enemy
    _hitting = TRUE;
    
    // Get time when bullet hits enemy
    _lastHitTimestamp = self.currentTimestamp;
    
    _theirHP -= 1;
    NSLog(@"%i theirHP", _theirHP);
    
    // Now go back and read comment after if (_hitting) in run method
}

- (void)gotHit {
    [super gotHit];
    _ourHP -= 1;
    if (_theirHP - _ourHP > 5 && _notMoving && _atTop)
    {
        _notMoving = false;
        [self turnGunLeft:90 - _currentAngle];
        [self moveBack:95];
        _currentAngle = 80;
        emergency = 1;
    }
    else if (_theirHP - _ourHP > 5 && _notMoving && !_atTop)
    {
        _notMoving = false;
        [self turnGunRight:_currentAngle];
        [self moveAhead:95];
        _currentAngle = -80;
        emergency = 1;
    }
    else if (_notMoving) {
        if ((_ourHP < _theirHP && _p2 && !_atTop) || (_ourHP < _theirHP && _p1 && _atTop))
        {
            _notMoving = false;
            //[self cancelActiveAction];
            [self turnGunRight:_currentAngle];
            [self moveAhead:270];
            [self turnGunLeft:170];
            _currentAngle = 80;
            _atTop = !_atTop;
            _shootLeft = true;
        }
        else if ((_ourHP < _theirHP && _p2 && _atTop) || (_ourHP < _theirHP && _p1 && !_atTop))
        {
            _notMoving = false;
            //[self cancelActiveAction];
            [self turnGunLeft:90 - _currentAngle];
            [self moveBack:270];
            [self turnGunRight:170];
            //_randomShoot = !_randomShoot;
            _currentAngle = 10;
            _atTop = !_atTop;
            _shootLeft = true;
        }
    }
    NSLog(@"%i ourHP", _ourHP);
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

