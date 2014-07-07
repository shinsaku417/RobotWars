//
//  Kamikaze.m
//  RobotWar
//
//  Created by Masa and Shin on 6/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Kamikaze.h"
#import "Bullet.h"

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateTurnaround,
    RobotStateFiring,
};

@implementation Kamikaze {
    RobotState _currentRobotState;
    
    int _ourHP;
    int _theirHP;
    
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
    BOOL _frontOrBack;
    int _corner;
}

- (void)run {
    _frontOrBack = true;
    _ourHP = 20;
    _theirHP = 20;
    
    
   
    
    // our starting position
    _p1 = false;
    _p2 = false;
    
    // whether our bullet hits enemy or not
    _hitting = false;
    
    // step 1: Move to the corner
    [self moveBack:200];
    if (self.headingDirection.x >= 0.f) {
        // starting top left
        _p1 = true;
        _corner = 1;
    } else {
        // starting bottom right
        _p2 = true;
        _corner = 3;
    }
    
    
    // direction barrel is moving
    _randomShoot = true;
    // our current angle
    _currentAngle = 0;
    [self turnRobotRight:90];
    [self moveBack:75];
    
    
    // step 2. Shoot one into the corner. Just in case when someone else is utilizing the corner
    [self turnGunLeft:60];
    _currentAngle += 60;
    [self shoot];
    while (true) {
        while(_corner == 1)
        {
        
        }
        
        while(_corner == 2)
        {
            // Search first
            if (_currentRobotState == RobotStateFiring) {
                if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
                    _currentRobotState = RobotStateDefault;
                } else {
                    CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
                    if (angle >= 0) {
                        [self turnGunRight:abs(angle)];
                        [self shoot];
                        //[self turnGunLeft:abs(angle)];
                        // Keep the current angle to prevent the bug. When the barrel goes beyond 90 or 0 degrees, it will cause the robot to get stuck when checking _currentAngle >= 90
                        //_currentAngle -= abs(angle);
                    } else {
                        [self turnGunLeft:abs(angle)];
                        [self shoot];
                        //[self turnGunRight:abs(angle)];
                        //_currentAngle += abs(angle);
                    }
                }
            }
            // If the bullet hits enemy, bulletHitEnemy method runs => read comment for that method first
            else {
                if (1==0&&_hitting)
                {
                // Here we use trigs
                // Calculate the angle between your position and enemy's position
                // _rect.origin.y + _rect.size.height/2 and _rect.origin.x + _rect.size.width to find barrel location (at the middle of robot).
                // p1 & p2 matters here
                if (_p1) {
                    if(_frontOrBack)
                    {
                        _angle = (atan2f((_rect.origin.y + _rect.size.height/2) - _hitPosition.y, _hitPosition.x - (_rect.origin.x + _rect.size.width/2))) * 180 /M_PI;
                    }
                    else
                    {
                        //_angle = (atan2f((_rect.origin.y + _rect.size.height/2) - _hitPosition.y,(_rect.origin.x + _rect.size.width/2)- _hitPosition.x)) * 180 /M_PI;
                        _angle = (atan2f((_rect.origin.y + _rect.size.height/2) - _hitPosition.y, (_rect.origin.x + _rect.size.width/2)- _hitPosition.x)) * 180 /M_PI;
                    }
                } else {
                    if(_frontOrBack)
                    {
                        _angle = (atan2f(_hitPosition.y - (_rect.origin.y + _rect.size.height/2), (_rect.origin.x + _rect.size.width/2)- _hitPosition.x)) * 180 /M_PI;
                    }
                    else
                    {
                        //_angle = (atan2f((_rect.origin.y + _rect.size.height/2) - _hitPosition.y, (_rect.origin.x + _rect.size.width/2)- _hitPosition.x)) * 180 /M_PI;
                        _angle = (atan2f((_rect.origin.y + _rect.size.height/2) - _hitPosition.y,(_rect.origin.x + _rect.size.width/2)- _hitPosition.x)) * 180 /M_PI;
                    }
                }
                
                // After getting the angle, subtract that angle from 90, and subtract that value from _currentAngle to calculate difference between current angle (now) and angle that you hit enemy (past).
                [self turnGunRight:(_currentAngle - (90 - _angle))];
                _currentAngle -= _currentAngle - (90 - _angle);
                [self shoot];
                
                // If 2 seconds have passed since last time the bullet hits an enemy, set _hitting to false, and revert back to spinning 90 degrees and shoot every small rotation
                if ((self.currentTimestamp - _lastHitTimestamp) > 2.f) {
                    _hitting = FALSE;
                    _currentRobotState = RobotStateDefault;
                }
            }
            else{
                
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
        
        while(_corner == 3)
        {
            // Search first
            if (_currentRobotState == RobotStateFiring) {
                if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
                    _currentRobotState = RobotStateDefault;
                } else {
                    CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
                    if (angle >= 0) {
                        [self turnGunRight:abs(angle)];
                        [self shoot];
                        //[self turnGunLeft:abs(angle)];
                        // Keep the current angle to prevent the bug. When the barrel goes beyond 90 or 0 degrees, it will cause the robot to get stuck when checking _currentAngle >= 90
                        //_currentAngle -= abs(angle);
                    } else {
                        [self turnGunLeft:abs(angle)];
                        [self shoot];
                        //[self turnGunRight:abs(angle)];
                        //_currentAngle += abs(angle);
                    }
                }
            }
            // If the bullet hits enemy, bulletHitEnemy method runs => read comment for that method first
            else {if (_hitting)  {
               
                    
                    
                        _angle = (atan2f(_hitPosition.y - (_rect.origin.y + _rect.size.height/2), (_rect.origin.x + _rect.size.width/2)- _hitPosition.x)) * 180 /M_PI;
                    
                
                // After getting the angle, subtract that angle from 90, and subtract that value from _currentAngle to calculate difference between current angle (now) and angle that you hit enemy (past).
                [self turnGunRight:(_currentAngle - (90 - _angle))];
                _currentAngle -= _currentAngle - (90 - _angle);
                [self shoot];
                
                // If 2 seconds have passed since last time the bullet hits an enemy, set _hitting to false, and revert back to spinning 90 degrees and shoot every small rotation
                if ((self.currentTimestamp - _lastHitTimestamp) > 2.f) {
                    _hitting = FALSE;
                    _currentRobotState = RobotStateDefault;
                }
            }
            else{
                
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
        
        while(_corner == 4)
        {
        
        }
        // Search first
        if (_currentRobotState == RobotStateFiring) {
            if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
                _currentRobotState = RobotStateDefault;
            } else {
                CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
                if (angle >= 0) {
                    [self turnGunRight:abs(angle)];
                    [self shoot];
                    //[self turnGunLeft:abs(angle)];
                    // Keep the current angle to prevent the bug. When the barrel goes beyond 90 or 0 degrees, it will cause the robot to get stuck when checking _currentAngle >= 90
                    //_currentAngle -= abs(angle);
                } else {
                    [self turnGunLeft:abs(angle)];
                    [self shoot];
                    //[self turnGunRight:abs(angle)];
                    //_currentAngle += abs(angle);
                }
            }
        }
        // If the bullet hits enemy, bulletHitEnemy method runs => read comment for that method first
        else {if (_hitting)  {
            // Here we use trigs
            // Calculate the angle between your position and enemy's position
            // _rect.origin.y + _rect.size.height/2 and _rect.origin.x + _rect.size.width to find barrel location (at the middle of robot).
            // p1 & p2 matters here
            if (_p1) {
                if(_frontOrBack)
                {
                    _angle = (atan2f((_rect.origin.y + _rect.size.height/2) - _hitPosition.y, _hitPosition.x - (_rect.origin.x + _rect.size.width/2))) * 180 /M_PI;
                }
                else
                {
                    //_angle = (atan2f((_rect.origin.y + _rect.size.height/2) - _hitPosition.y,(_rect.origin.x + _rect.size.width/2)- _hitPosition.x)) * 180 /M_PI;
                    _angle = (atan2f((_rect.origin.y + _rect.size.height/2) - _hitPosition.y, (_rect.origin.x + _rect.size.width/2)- _hitPosition.x)) * 180 /M_PI;
                }
            } else {
                if(_frontOrBack)
                {
                _angle = (atan2f(_hitPosition.y - (_rect.origin.y + _rect.size.height/2), (_rect.origin.x + _rect.size.width/2)- _hitPosition.x)) * 180 /M_PI;
                }
                else
                {
                    //_angle = (atan2f((_rect.origin.y + _rect.size.height/2) - _hitPosition.y, (_rect.origin.x + _rect.size.width/2)- _hitPosition.x)) * 180 /M_PI;
                    _angle = (atan2f((_rect.origin.y + _rect.size.height/2) - _hitPosition.y,(_rect.origin.x + _rect.size.width/2)- _hitPosition.x)) * 180 /M_PI;
                }
            }
            
            // After getting the angle, subtract that angle from 90, and subtract that value from _currentAngle to calculate difference between current angle (now) and angle that you hit enemy (past).
            [self turnGunRight:(_currentAngle - (90 - _angle))];
            _currentAngle -= _currentAngle - (90 - _angle);
            [self shoot];
            
            // If 2 seconds have passed since last time the bullet hits an enemy, set _hitting to false, and revert back to spinning 90 degrees and shoot every small rotation
            if ((self.currentTimestamp - _lastHitTimestamp) > 2.f) {
                _hitting = FALSE;
                _currentRobotState = RobotStateDefault;
            }
        }
        else{
            
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
                if (_currentAngle >= 90 || _currentAngle < 0) {
                    _randomShoot = !_randomShoot;
                }
                
            }
        }
        }
        
    }//<-main while bracket
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
    if (_ourHP < _theirHP) {
        if (_corner ==3) {
            [self moveAhead:270];
            [self turnGunRight:(_currentAngle-90)];
            _currentAngle = 0;
            _corner = 2;
        }
        else if(_corner ==2)
        {
            [self moveBack:270];
            [self turnGunRight:(_currentAngle+90)];
            
            _currentAngle = 0;
            _corner = 3;
        }
        else {
            [self moveBack:270];
            [self turnGunRight:(_currentAngle)];
            _currentAngle = 0;
            _frontOrBack = !_frontOrBack;
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

