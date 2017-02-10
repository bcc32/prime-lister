local primes = { 2, 3 }
local limit = tonumber(ARGV[1])
local candidate = primes[#primes] + 2

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

for _, p in ipairs(primes) do
    redis.call('rpush', KEYS[1], p)
end
return {ok=#primes}
