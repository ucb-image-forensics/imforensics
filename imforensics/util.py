from __future__ import absolute_import

import numpy as np
import matlab

numpy2matlb_type = {
    np.int64         : matlab.int64,
    np.bool_         : matlab.int8,
    np.int8          : matlab.int8,
    np.int16         : matlab.int16,
    np.int32         : matlab.int32,
    np.int64         : matlab.int64,
    np.uint8         : matlab.uint8,
    np.uint16        : matlab.uint16,
    np.uint32        : matlab.uint32,
    np.uint64        : matlab.uint64,
    np.float16       : matlab.single,
    np.float32       : matlab.single,
    np.float64       : matlab.double
}

def numpy2matlb(np_arr):
    np_type = np_arr.dtype.type
    ml_arr_klass = numpy2matlb_type.get(np_type, None)
    if not ml_arr_klass:
        raise ValueError('Cannot convert numpy type {0} to matlab array.'.format(np_type))
    ml_arr = ml_arr_klass(np_arr.flatten().tolist())
    ml_arr.reshape(np_arr.shape)
    return ml_arr
