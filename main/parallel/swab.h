#define swab32(x) \
({ \
        u_int32_t *__x = (u_int32_t *)(x); \
        ((u_int32_t)( \
                (((u_int32_t)(*__x) & (u_int32_t)0x000000ffUL) << 24) | \
                (((u_int32_t)(*__x) & (u_int32_t)0x0000ff00UL) <<  8) | \
                (((u_int32_t)(*__x) & (u_int32_t)0x00ff0000UL) >>  8) | \
                (((u_int32_t)(*__x) & (u_int32_t)0xff000000UL) >> 24) )); \
})

#define swab64(x) \
({ \
        u_int64_t *__x = (u_int64_t *)(x); \
        ((u_int64_t)( \
                (u_int64_t)(((u_int64_t)(*__x) & (u_int64_t)0x00000000000000ffULL) << 56) | \
                (u_int64_t)(((u_int64_t)(*__x) & (u_int64_t)0x000000000000ff00ULL) << 40) | \
                (u_int64_t)(((u_int64_t)(*__x) & (u_int64_t)0x0000000000ff0000ULL) << 24) | \
                (u_int64_t)(((u_int64_t)(*__x) & (u_int64_t)0x00000000ff000000ULL) <<  8) | \
                (u_int64_t)(((u_int64_t)(*__x) & (u_int64_t)0x000000ff00000000ULL) >>  8) | \
                (u_int64_t)(((u_int64_t)(*__x) & (u_int64_t)0x0000ff0000000000ULL) >> 24) | \
                (u_int64_t)(((u_int64_t)(*__x) & (u_int64_t)0x00ff000000000000ULL) >> 40) | \
                (u_int64_t)(((u_int64_t)(*__x) & (u_int64_t)0xff00000000000000ULL) >> 56) )); \
})
