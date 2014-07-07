//
//  Kamikaze.m
//  RobotWar
//
//  Created by Masa and Shin on 6/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "MutekiRobot.h"
#import "Bullet.h"

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateTurnaround,
    RobotStateFiring,
    RobotStateSearching
};

@implementation MutekiRobot {
    RobotState _currentRobotState;
    
    CGPoint _hitPosition;
    CGRect _rect;
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
    BOOL _randomShoot;
    BOOL _p1;
    BOOL _p2;
    BOOL _hitting;
    double _currentAngle;
    CGFloat _lastHitTimestamp;
    CGFloat _angle;
    
    Robot *detect;
    BOOL _alreadyDetect;
}

- (void)run {
    // our current angle
    _currentAngle = 0;
    
    // direction barrel is moving
    _randomShoot = true;
    
    // our starting position
    _p1 = false;
    _p2 = false;
    
    // whether our bullet hits enemy or not
    _hitting = false;
    
    // step 1: Move to the corner
    [self moveBack:25];
    if (self.headingDirection.x >= 0.f) {
        // starting top left
        _p1 = true;
    } else {
        // starting bottom right
        _p2 = true;
    }
    [self turnRobotRight:90];
    [self moveBack:75];
    
    // step 2. Shoot one into the corner. Just in case when someone else is utilizing the corner
    [self turnGunLeft:60];
    _currentAngle += 60;
    [self shoot];
    while (true) {
        // Search first
        if (_alreadyDetect) {
            [self aimGunAtEnemy:detect];
            [self shoot];
        } else
        // If the bullet hits enemy, bulletHitEnemy method runs => read comment for that method first
        if (_hitting)  {
            // Here we use trigs
            // Calculate the angle between your position and enemy's position
            // _rect.origin.y + _rect.size.height/2 and _rect.origin.x + _rect.size.width to find barrel location (at the middle of robot).
            // p1 & p2 matters here
            if (_p1) {
//                NSLog(@"%f x1", _hitPosition.x);
//                NSLog(@"%f y1", _hitPosition.y);
//                NSLog(@"%f whereiamx1", _rect.origin.x);
//                NSLog(@"%f whereiamy1", _rect.origin.y);
                _angle = (atan2f((_rect.origin.y - 0.068 + _rect.size.height/2) - _hitPosition.y, _hitPosition.x - (_rect.origin.x + 0.481 + _rect.size.width))) * 180 /M_PI;
            } else {
                _angle = (atan2f(_hitPosition.y - (_rect.origin.y + _rect.size.height/2), (_rect.origin.x + _rect.size.width)- _hitPosition.x)) * 180 /M_PI;
            }
            //NSLog(@"%f", _angle);
            
            // After getting the angle, subtract that angle from 90, and subtract that value from _currentAngle to calculate difference between current angle (now) and angle that you hit enemy (past).
            [self turnGunRight:(_currentAngle - (90 - _angle))];
            _currentAngle -= _currentAngle - (90 - _angle);
            
            [self shoot];
        }
        
        // If 2 seconds have passed since last time the bullet hits an enemy, set _hitting to false, and revert back to spinning 90 degrees and shoot every small rotation
        if ((self.currentTimestamp - _lastHitTimestamp) > 3.f) {
            _hitting = FALSE;
        }
        if (_hitting == FALSE) {
            _currentRobotState = RobotStateSearching;
            
            if (_currentRobotState == RobotStateSearching) {
                // I'm pretty sure we don't need RoborStateSearching, but oh wells.
                _currentRobotState = RobotStateDefault;
            }
            
            if (_currentRobotState == RobotStateDefault) {
                // When randomShoot = true, rotate barrel to the left
                if (_randomShoot) {
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
                // If current angle is above 90 or below 0, change the direction. We are always at the corner so don't need to rotate more than these values. At least for now.
                if (_currentAngle >= 90 || _currentAngle <= 0) {
                    _randomShoot = !_randomShoot;
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
    
    // Now go back and read comment after if (_hitting) in run method
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    _alreadyDetect = true;
    detect = robot;
}

- (void)aimGunAtEnemy:(Robot *)enemy {
    CGPoint robotCenter = ccp(enemy.robotBoundingBox.origin.x + enemy.robotBoundingBox.size.width/2, enemy.robotBoundingBox.origin.y + enemy.robotBoundingBox.size.height/2);
    float angleToEnemy = [self angleBetweenGunHeadingDirectionAndWorldPosition:robotCenter];
    angleToEnemy > 0 ? [self turnGunRight:angleToEnemy] : [self turnGunLeft:-angleToEnemy];
}

@end

