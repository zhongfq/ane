//
// $id:lamewrapper.cpp O $
//

#include "lamewrapper.h"

#include <string.h>
#include <stdlib.h>
#include <unistd.h>

static size_t bufread(void *data, size_t size, size_t count, buffer_t *buf) {
    size_t num = size * count;
    if (buf->capacity - buf->pos < size) {
        return 0;
    } else if (buf->pos + num > buf->capacity) {
        count = (buf->capacity - buf->pos) / size;
        num = size * count;
    }
    
    memcpy(data, buf->data + buf->pos, num);
    buf->pos += num;
    return count;
}

static size_t bufwrite(const void *data, size_t size, size_t count, buffer_t *buf) {
    size_t num = size * count;
    size_t len = buf->capacity;
    if (buf->pos + num > len) {
        len = len == 0 ? BUFFER_SIZE : len;
        while (len < buf->capacity + num) {
            len <<= 2;
        }
    }
    buf->data = (char *)realloc(buf->data, len);
    buf->capacity = len;
    memcpy(buf->data + buf->pos, data, num);
    buf->pos += num;
    
    return num;
}

lamewrapper::lamewrapper(int kbps)
:_convert_thread(nullptr)
,_quit(false)
,_done(false)
{
    _buf = (buffer_t *)malloc(sizeof(*_buf));
    _buf->data = nullptr;
    _buf->capacity = 0;
    _buf->pos = 0;
    
    _lame = lame_init();
    lame_set_in_samplerate(_lame, 44100);
    lame_set_num_channels(_lame, 2);
    lame_set_VBR(_lame, vbr_abr);
    lame_set_VBR_mean_bitrate_kbps(_lame, kbps);
    lame_init_params(_lame);
    
    _convert_thread = new std::thread(&lamewrapper::start, this);
}

lamewrapper::~lamewrapper()
{
    if (_convert_thread) {
        _quit = true;
        _cond.notify_one();
        _convert_thread->join();
        delete _convert_thread;
    }
    
    for (auto buf : _wavbufs) {
        free(buf->data);
        free(buf);
    }
    
    lame_close(_lame);
    free(_buf->data);
    free(_buf);
}

void lamewrapper::push(buffer_t *buf)
{
    std::unique_lock<std::mutex> lock(_mutex);
    _wavbufs.push_back(buf);
    _cond.notify_one();
}


void lamewrapper::flush()
{
    if (!_done) {
        _done = true;
        _cond.notify_one();
        _convert_thread->join();
        delete _convert_thread;
        _convert_thread = nullptr;
    }
}

buffer_t *lamewrapper::buffer()
{
    return _buf;
}

void lamewrapper::start()
{    
    short input[BUFFER_SIZE * 2];
    unsigned char output[BUFFER_SIZE];
    
    bool has_data = false;
    int num_read, num_write;
    
    while (true) {
        if (_quit) {
            return;
        }
        
        buffer_t *buf = nullptr;
        _mutex.lock();
        if (_wavbufs.size() > 0) {
            buf = _wavbufs.front();
            _wavbufs.pop_front();
        }
        _mutex.unlock();
        
        if (buf) {
            do {
                num_read = (int)bufread(input, sizeof(short) * 2, BUFFER_SIZE, buf);
                if (num_read) {
                    has_data = true;
                    num_write = lame_encode_buffer_interleaved(_lame, input, (int)num_read, output, BUFFER_SIZE);
                    bufwrite(output, sizeof(unsigned char), num_write, _buf);
                }
            } while (num_read != 0);
            free(buf->data);
            free(buf);
        } else if (_done) {
            if (has_data) {
                num_write = lame_encode_flush(_lame, output, BUFFER_SIZE);
                if (num_write > 0) {
                    bufwrite(output, sizeof(unsigned char), num_write, _buf);
                }
            }
            break;
        } else {
            std::unique_lock<std::mutex> lock(_mutex);
            _cond.wait(lock);
        }
    }
}

