#include <vector>

extern void write(unsigned char const * pkt, int cs);
int main()
{
    for(int i = 0; i < 1000; ++i) {
        std::vector<unsigned char> buffer(32 * 3 * 8);
        for(auto it = buffer.begin(); it != buffer.end(); ++it) {
            *it = rand();
        }
        write(buffer.data(), 0);
    }
    return 0;
}
