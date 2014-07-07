//
//  Kamikaze.m
//  RobotWar
//
//  Created by Masa and Shin on 6/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//
// Bugs vs DemiPixel (when p2)

#import "ShingekiNoKyojin4.h"
#import "Bullet.h"

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateTurnaround,
    RobotStateFiring,
};

@implementation ShingekiNoKyojin4 {
    RobotState _currentRobotState;
    
    int _ourHP;
    int _theirHP;
    
    CGPoint _hitPosition;
    CGRect _rect;
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
}

- (void)run {
    _random = (arc4random() % 2) + 1;
    _atTop = true;
    _ourHP = 20;
    _theirHP = 20;
    
    // our starting position
    _p1 = false;
    _p2 = false;
    
    // whether our bullet hits enemy or not
    _hitting = false;
    
    // step 1: Move to the corner
    [self moveBack:50];
    if (self.headingDirection.x >= 0.f) {
        // starting top left
        _p1 = true;
        _atTop = false;
    } else {
        // starting bottom right
        _p2 = true;
        _atTop = true;
    }
    
    
    // direction barrel is moving. true = left, false = right
    //_randomShoot = true;
    _shootLeft = false;
    //_shootRight = false;
    // our current angle
    _currentAngle = 0;
    [self turnRobotRight:90];
    [self moveAhead:200];
    [self turnGunLeft:90];
    
    
    // step 2. Shoot one into the corner. Just in case when someone else is utilizing the corner
    //[self turnGunLeft:60];
    //_currentAngle += 60;
    //[self shoot];
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
            if (_hitting) {
                if (_p1 && _atTop) {
                    _angle = (atan2f((_rect.origin.y + _rect.size.height/2) - _hitPosition.y, _hitPosition.x - (_rect.origin.x + _rect.size.width/2))) * 180 /M_PI;
                    [self turnGunRight:(_currentAngle - (90 - _angle))];
                    _currentAngle -= _currentAngle - (90 - _angle);
                    [self shoot];
                }
                if (_p2 && !_atTop) {
                    _angle = (atan2f(_hitPosition.y - (_rect.origin.y + _rect.size.height/2), (_rect.origin.x + _rect.size.width/2)- _hitPosition.x)) * 180 /M_PI;
                    [self turnGunRight:(_currentAngle - (90 - _angle))];
                    _currentAngle -= _currentAngle - (90 - _angle);
                    [self shoot];
                }
                if (_p1 && !_atTop) {
                    _angle = (atan2f(_hitPosition.y - (_rect.origin.y + _rect.size.height/2), _hitPosition.x - (_rect.origin.x + _rect.size.width/2))) * 180 /M_PI;
                    [self turnGunLeft:_angle - _currentAngle];
                    _currentAngle += (_angle - (int)_currentAngle);
                    [self shoot];
                }
                if (_p2 && _atTop) {
                    _angle = (atan2f((_rect.origin.y + _rect.size.height/2) - _hitPosition.y, (_rect.origin.x + _rect.size.width/2) - _hitPosition.x)) * 180 /M_PI;
                    [self turnGunLeft:_angle - _currentAngle];
                    _currentAngle += (_angle - _currentAngle);
                    [self shoot];
                }
                if ((self.currentTimestamp - _lastHitTimestamp) > 2.75f) {
                    _hitting = false;
                }
            }
            else if (_currentRobotState == RobotStateDefault) {
                NSLog(@"%f currentangle", _currentAngle);
                
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
                if (_currentAngle >= 85)
                {
                    _shootLeft = false;
                    //_shootRight = true;
                }
                if (_currentAngle <= 5) {
                    _shootLeft = true;
                    //_shootRight = false;
                }
                
            }
        }
    }
}

- (void)bulletHitEnemy:(Bullet *)bullet {
    // There are a couple of neat things you could do in this handler
    [self cancelActiveAction];
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
    if ((_ourHP < _theirHP && _p2 && !_atTop) || (_ourHP < _theirHP && _p1 && _atTop))
    {
        [self cancelActiveAction];
        [self turnGunRight:_currentAngle];
        [self moveAhead:270];
        [self turnGunLeft:180];
        _currentAngle = 90;
        _atTop = !_atTop;
    }
    else if ((_ourHP < _theirHP && _p2 && _atTop) || (_ourHP < _theirHP && _p1 && !_atTop))
    {
        [self cancelActiveAction];
        [self turnGunLeft:90 - _currentAngle];
        [self moveBack:270];
        [self turnGunRight:180];
        //_randomShoot = !_randomShoot;
        _currentAngle = 0;
        _atTop = !_atTop;
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

