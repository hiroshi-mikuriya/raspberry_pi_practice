//
//  selfball_simulator.cpp
//  selfball_simulator
//
//  Created by hiroshi on 2018/04/21.
//  Copyright © 2018年 fxat. All rights reserved.
//

#include <iostream>
#include "selfball_simulator.hpp"
#include "selfball_simulatorPriv.hpp"

void selfball_simulator::HelloWorld(const char * s)
{
    selfball_simulatorPriv *theObj = new selfball_simulatorPriv;
    theObj->HelloWorldPriv(s);
    delete theObj;
};

void selfball_simulatorPriv::HelloWorldPriv(const char * s) 
{
    std::cout << s << std::endl;
};

