//
//  DemiPixel.m
//  RobotWar
//
//  Created by Kevin Li on 6/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "DemiPixel.h"
#import "GameConstants.h"
#import "Robot.h"
#import "Robot_Framework.h"
#import "Bullet.h"

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateSearching,
    RobotStateRapidFire,
    RobotStateShootAndRun,
    RobotStateEscape
};

@implementation DemiPixel {
    RobotState _currentState;
    
    CGPoint _lastEnemyPosition;
    CGFloat _lastDetectedTime;
    CGFloat _lastHitTime;
    
    NSInteger _hitStreak;
    
    int hitCount;
    
    BOOL rapidFireLeft;
    
    int enemyHealth;
    int health;
    
    float searchAmount;
}

const bool LOG = TRUE; // Everything
const bool LOG_STATE = FALSE;
const bool LOG_STREAK = FALSE;
const bool LOG_NEW_LOCATION = FALSE;

- (void)run {
    searchAmount = 0;
    hitCount = 0;
    enemyHealth = 20;
    health = 20;
    _currentState = RobotStateSearching;
    [self logChange];
    while (true) {
        if (_currentState != RobotStateSearching) searchAmount = 0;
        if ([self currentTimestamp] - _lastDetectedTime > 3.f) {
            _currentState = RobotStateSearching;
            [self logChange];
            _hitStreak = 0;
        }
        if (_currentState == RobotStateShootAndRun) {
            if (_hitStreak >= 1) {
                _currentState = RobotStateRapidFire;
                [self logChange];
            }
            [self aimGunAtPoint:_lastEnemyPosition];
            [self shoot];
            int width = self.robotBoundingBox.size.width;
            if (enemyHealth >= health) [self moveRandomMin:width*2 max:width*2];
        }
        else if (_currentState == RobotStateRapidFire) {
            [self aimGunAtPoint:_lastEnemyPosition];
            [self shoot];
            if (enemyHealth > health) {
                _currentState = RobotStateShootAndRun;
                [self logChange];
                _hitStreak = 0;
            }
            
            else {
                //                if (rapidFireLeft) {
                //                    [self turnGunLeft:10];
                //                    rapidFireLeft = false;
                //                }
                //                else {
                //                    [self turnGunRight:10];
                //                    rapidFireLeft = true;
                //                }
                [self aimGunAtPoint:_lastEnemyPosition];
                [self shoot];
            }
        }
        else if (_currentState == RobotStateSearching) {
            if (searchAmount <= 40) { [self turnGunRight:10]; searchAmount += 10; }
            if (searchAmount < 360 && searchAmount > 40) { [self turnGunRight:40]; searchAmount += 40; }
            if (searchAmount >= 360) { [self turnGunRight:15]; searchAmount += 15; }
            [self shoot];
        }
        else if (_currentState == RobotStateEscape) {
            int width = self.robotBoundingBox.size.width;
            int turnAngle = [self angleBetweenHeadingDirectionAndWorldPosition:_lastEnemyPosition] - 30;
            turnAngle > 0 ? [self turnRobotRight:turnAngle] : [self turnRobotLeft:-turnAngle];
            
            [self aimGunAtPoint:_lastEnemyPosition];
            [self shoot];
            
            [self moveBack:width*8];
            if (health > enemyHealth) {
                _currentState = RobotStateShootAndRun;
            }
        }
    }
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    _lastEnemyPosition = position;
    if (LOG && LOG_NEW_LOCATION) NSLog(@"New Enemy Location");
    //if (health < enemyHealth) { _currentState = RobotStateEscape; [self logChange]; }
    _lastDetectedTime = [self currentTimestamp];
    if (_currentState == RobotStateSearching) _currentState = RobotStateShootAndRun;
    if (abs(position.x - [self robotNode].position.y) < 50 &&
        abs(position.y - [self robotNode].position.y) < 50) {
        [self logChange];
    }
}

- (void)logChange {
    if (LOG && LOG_STATE) {
        switch (_currentState) {
            case RobotStateRapidFire: NSLog(@"Rapid Fire"); break;
            case RobotStateShootAndRun: NSLog(@"Shoot and Run"); break;
            case RobotStateSearching: NSLog(@"Searching"); break;
            case RobotStateEscape: NSLog(@"Escape"); break;
        }
    }
}

- (void)bulletHitEnemy:(Bullet *)bullet {
    enemyHealth--;
    NSLog(@"%i, %i",health,enemyHealth);
    if (health > enemyHealth) { _hitStreak = 2; [self cancelActiveAction]; } // Go to Rapid Fire
    _lastEnemyPosition = bullet.position;
    if (LOG && LOG_NEW_LOCATION) NSLog(@"New Enemy Location");
    _lastDetectedTime = [self currentTimestamp];
    _hitStreak++;
    if (LOG && LOG_STREAK) NSLog(@"Hit Streak: %ld",(long)_hitStreak);
    _lastHitTime = [self currentTimestamp];
    if (_currentState == RobotStateSearching) {
        _currentState = RobotStateShootAndRun;
        [self logChange];
    }
}

- (void)aimGunAtPoint:(CGPoint)point {
    float angleToEnemy = [self angleBetweenGunHeadingDirectionAndWorldPosition:point];
    if (LOG) NSLog(@"Turn %f",angleToEnemy);
    angleToEnemy > 0 ? [self turnGunRight:angleToEnemy] : [self turnGunLeft:-angleToEnemy];
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)hitAngle {
    //    if (hitAngle >= 0) {
    //        [self turnRobotLeft:abs(hitAngle/1.5)];
    //    }
    //    else {
    //        [self turnRobotRight:abs(hitAngle/1.5)];
    //    }
    //    [self moveAhead:30];
    switch (hitDirection) {
        case RobotWallHitDirectionFront:
            [self turnRobotRight:100];
            break;
        case RobotWallHitDirectionRear:
            [self turnRobotRight:100];
            break;
        case RobotWallHitDirectionLeft:
            [self turnRobotRight:100];
            [self moveAhead:20];
            break;
        case RobotWallHitDirectionRight:
            [self turnRobotRight:100];
            [self moveAhead:20];
            break;
        default:
            break;
    }
}

- (void)turnToAngle:(float)angle {
    if (LOG) NSLog(@"Move to angle %f",angle);
    float oppositeAngle = [self positiveAngle:angle - 180];
    if (self.robotNode.rotation < angle < oppositeAngle) {
        [self turnRobotLeft:angle];
    }
    else {
        [self turnRobotRight:angle];
    }
}

- (void)gotHit {
    hitCount++;
    health--;
    int width = self.robotBoundingBox.size.width;
    // [self cancelActiveAction];
    if (_hitStreak < 2 && hitCount >= 2) { [self moveRandomMin:width max:width]; hitCount = 0; }
    if (_currentState == RobotStateRapidFire) {
        _hitStreak -= 1;
        if (_hitStreak < 0) _hitStreak = 0;
        if (LOG && LOG_STREAK) NSLog(@"Hit Streak: %ld",(long)_hitStreak);
    }
}

- (void)moveRandomMin:(int)min max:(int)max{
    [self turnRobotLeft:4];
    if (max > min) [self moveAhead:arc4random() % (max - min) + min];
    else [self moveAhead:min];
}



- (float)angleForX:(float)x y:(float)y {
    float angle = atan(y/x);
    
    if (x > 0 ^ y > 0) {
        angle = -angle;
    }
    
    return angle;
}

- (float)positiveAngle:(float)angle {
    if (angle >= 0) {   //Angle is already positive
        return angle;
    }
    return 360 - abs(angle);
}


@end