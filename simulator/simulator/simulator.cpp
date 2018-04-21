//
//  simulator.cpp
//  simulator
//
//  Created by hiroshi on 2018/04/21.
//  Copyright © 2018年 fxat. All rights reserved.
//

#include <iostream>
#include "simulator.hpp"
#include "simulatorPriv.hpp"

void simulator::HelloWorld(const char * s)
{
    simulatorPriv *theObj = new simulatorPriv;
    theObj->HelloWorldPriv(s);
    delete theObj;
};

void simulatorPriv::HelloWorldPriv(const char * s) 
{
    std::cout << s << std::endl;
};

