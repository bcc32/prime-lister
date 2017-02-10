local primes = { 2, 3 }
local key = KEYS[1]
local limit = tonumber(ARGV[1])
local candidate = primes[#primes] + 2

redis.log(redis.LOG_DEBUG, 'computing prime list')

while #primes < limit do
    local ok = true
    for _, p in ipairs(primes) do
        if p * p > candidate then
            break
        elseif candidate % p == 0 then
            ok = false
            break
        end
    end
    if ok then table.insert(primes, candidate) end
    candidate = candidate + 2
end

redis.log(redis.LOG_DEBUG, 'inserting primes into redis key ' .. key .. '...')

for _, p in ipairs(primes) do
    redis.call('rpush', key, p)
end

redis.log(redis.LOG_DEBUG, 'done inserting primes')

return #primes
