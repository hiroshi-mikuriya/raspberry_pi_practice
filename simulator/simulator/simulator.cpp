#include <opencv2/opencv.hpp>

namespace {
    const float inner = 230;
    const float outer = inner + 10;
    const float light = 5;
    const cv::Size canvas_size(500, 500);
}

extern "C"
void write(unsigned char const * pkt, int cs)
{
    cv::Mat canvas = cv::Mat::zeros(canvas_size, CV_8UC3);
    cv::Point c(canvas.cols / 2, canvas.rows / 2);
    for(int i = 0; i < 32; ++i) {
        double a = 2 * CV_PI * (i % 16) / 16;
        double r = (i < 16) ? inner : outer;
        cv::Point2f pt(c.x + sin(a) * r, c.y + cos(a) * r);
        auto rgb = 3 + pkt + 3 * i;
        cv::Scalar color(rgb[2], rgb[1], rgb[0]);
        cv::circle(canvas, pt, light, color, CV_FILLED);
    }
    cv::imshow("simulator", canvas);
    cv::waitKey(1);
}

