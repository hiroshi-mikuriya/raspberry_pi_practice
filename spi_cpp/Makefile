### Defines ####################################################################
UNAME := ${shell uname}
CXX       := g++
CXXFLAGS  := -Wall -std=c++0x -v $(CXXDEFS)

TARGET    := spicpp
PROJ_ROOT := $(realpath ./)
SRCS      := main.cpp
LIBS      := -lpthread \
	     -ldl \
		 -lbcm2835 \
	     -lm
ifeq ($(ENABLE_REAL_3D_LED_CUBE), true)
SRCS := $(SRCS) main.cpp
LIBS := $(LIBS) -lbcm2835
endif

OBJS      := $(SRCS:.cpp=.o)

### Rules ######################################################################

.PHONY: all
all: $(TARGET)
.PHONY: make
make: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) -v -o $@ $(OBJS) $(LIBS)

.PHONY: clean
clean:
	$(RM) -f $(TARGET) *.o

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $<
