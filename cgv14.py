import random

def SecAnd(x0, x1, y0, y1, r01):
    r10 = (r01 ^ (x0 & y1)) ^ (x1 & y0)
    z0 = (x0 & y0) ^ r01
    z1 = (x1 & y1) ^ r10
    return z0, z1

def getBit(X, pos):
    return (X >> pos) & 1

def setBit(X, pos, v):
    if v == 0:
        return X & ~(1 << pos)
    else:
        return X | (1 << pos)


def SecAdd(x0, x1, y0, y1, k, R):
    c0j = 0
    c1j = 0
    c0 = 0
    c1 = 0

    xy0 = 0
    xy1 = 0
    xc0 = 0
    xc1 = 0
    yc0 = 0
    yc1 = 0

    for j in range(0, k - 1):
        x0j = getBit(x0, j)
        x1j = getBit(x1, j)
        y0j = getBit(y0, j)
        y1j = getBit(y1, j)
        
        xy0j, xy1j = SecAnd(x0j, x1j, y0j, y1j, R[j*3])
       
        xc0j, xc1j = SecAnd(x0j, x1j, c0j, c1j, R[j*3+1])

        yc0j, yc1j = SecAnd(y0j, y1j, c0j, c1j, R[j*3+2])
        
        c0j = xy0j ^ xc0j ^ yc0j 
        c1j = xy1j ^ xc1j ^ yc1j

        c0 = setBit(c0, j+1, c0j)
        c1 = setBit(c1, j+1, c1j)

        xy0 = setBit(xy0, j, xy0j)
        xy1 = setBit(xy1, j, xy1j)
        xc0 = setBit(xc0, j, xc0j)
        xc1 = setBit(xc1, j, xc1j)
        yc0 = setBit(yc0, j, yc0j)
        yc1 = setBit(yc1, j, yc1j)

    z0 = x0 ^ y0 ^ c0
    z1 = x1 ^ y1 ^ c1


    return z0, z1
    

def ConvertAB(A0, A1, R0, R1, k, R):
    B0 = A0 ^ R0
    B1 = R0
    C0 = A1 ^ R1
    C1 = R1
    return SecAdd(B0, B1, C0, C1, k, R)

def test_SecAnd():
    for _ in range(0, 10000):
        x = random.randint(0, 0xffff)
        y = random.randint(0, 0xffff)
        x0 = random.randint(0, 0xffff)
        x1 = x ^ x0
        y0 = random.randint(0, 0xffff)
        y1 = y ^ y0

        r01 = random.randint(0, 0xffff)

        z0, z1 = SecAnd(x0, x1, y0, y1, r01)
        assert((z0 ^ z1) == (x & y))
        

def test_SecAdd():
    for _ in range(0, 10000):
        x = random.randint(0, 0xffff)
        y = random.randint(0, 0xffff)
        x0 = random.randint(0, 0xffff)
        x1 = x ^ x0
        y0 = random.randint(0, 0xffff)
        y1 = y ^ y0
        k = 16
        R = [random.randint(0, 1) for _ in range(0, (k-1)*3)]
        z0, z1 = SecAdd(x0, x1, y0, y1, k, R)
        assert((z0 ^ z1) == ((x + y) & 0xffff))
        exit(0)

def test_getBit():
    for _ in range(0, 10000):
        X = random.randint(0, 0xffff)
        pos = random.randint(0, 15)
        X_bit_test0 = int(((f'0b{X:016b}')[::-1])[pos])
        X_bit_test1 = getBit(X, pos)
        assert(X_bit_test0 == X_bit_test1)

def test_setBit():
    for _ in range(0, 10000):
        X = random.randint(0, 0xffff)
        pos = random.randint(0, 15)
        v = random.randint(0,1)
        X_test0 = (f'0b{X:016b}'[2:])[::-1]
        X_test0 = X_test0[:pos] + str(v) + X_test0[pos + 1:]
        X_test0 = int(X_test0[::-1], 2)
        X_test1 = setBit(X, pos, v)
        assert(X_test0 == X_test1)

def test_ConvertAB():
    for _ in range(0, 10000):
        A = random.randint(0, 0xffff)
        A0 = random.randint(0, 0xffff)
        A1 = (A - A0) & 0xffff
        R0 = random.randint(0, 0xffff)
        R1 = random.randint(0, 0xffff)
        k = 16
        R = [random.randint(0, 1) for _ in range(0, (k-1)*3)]
        z0, z1 = ConvertAB(A0, A1, R0, R1, k, R)
        assert((z0 ^ z1) == A)

def main():
    #test_SecAnd()
    #test_getBit()
    #test_setBit()
    #test_SecAdd()
    test_ConvertAB()


if __name__ == "__main__":
    main()
     