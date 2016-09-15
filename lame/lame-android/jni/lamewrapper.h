//
// $id:lamewrapper.h O $
//

#ifndef __LAMEWRAPPER_H__
#define __LAMEWRAPPER_H__

#include <stdio.h>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <deque>

#include "lame/lame.h"

#define BUFFER_SIZE 8192

typedef struct {
    size_t capacity;
    long pos;
    char *data;
} buffer_t;

class lamewrapper {
public:
    lamewrapper(int kbps = 32);
    ~lamewrapper();
    
    void push(buffer_t *buf);
    void flush();
    buffer_t *buffer();
private:
    void start();
private:
    std::deque<buffer_t *> _wavbufs;
    std::mutex _mutex;
    std::condition_variable _cond;
    std::thread *_convert_thread;
    buffer_t *_buf;
    lame_t _lame;
    bool _quit;
    bool _done;
};

#endif