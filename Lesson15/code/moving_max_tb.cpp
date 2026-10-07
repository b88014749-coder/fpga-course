#include <stdio.h>
#include "moving_max.h"

/*
 * Reference implementation:
 * Directly finds the maximum of in[n-7] ... in[n].
 * This is intentionally a straightforward implementation,
 * independent of moving_max().
 */
static void reference(const int in_data[N_SAMPLES],
                      int golden[N_SAMPLES]) {
    for (int n = 0; n < N_SAMPLES; n++) {
        int start = n - WINDOW + 1;
        if (start < 0)
            start = 0;

        int max = in_data[start];

        for (int k = start + 1; k <= n; k++) {
            if (in_data[k] > max)
                max = in_data[k];
        }

        golden[n] = max;
    }
}

int main() {
    int errors = 0;

    /*
     * At least five different input vectors.
     * Each test has exactly N_SAMPLES (= 64) elements.
     */
    const int test_vectors[5][N_SAMPLES] = {
        /* Test 0: increasing */
        {
             0,  1,  2,  3,  4,  5,  6,  7,
             8,  9, 10, 11, 12, 13, 14, 15,
            16, 17, 18, 19, 20, 21, 22, 23,
            24, 25, 26, 27, 28, 29, 30, 31,
            32, 33, 34, 35, 36, 37, 38, 39,
            40, 41, 42, 43, 44, 45, 46, 47,
            48, 49, 50, 51, 52, 53, 54, 55,
            56, 57, 58, 59, 60, 61, 62, 63
        },

        /* Test 1: decreasing */
        {
            63, 62, 61, 60, 59, 58, 57, 56,
            55, 54, 53, 52, 51, 50, 49, 48,
            47, 46, 45, 44, 43, 42, 41, 40,
            39, 38, 37, 36, 35, 34, 33, 32,
            31, 30, 29, 28, 27, 26, 25, 24,
            23, 22, 21, 20, 19, 18, 17, 16,
            15, 14, 13, 12, 11, 10,  9,  8,
             7,  6,  5,  4,  3,  2,  1,  0
        },

        /* Test 2: alternating positive/negative */
        {
             10, -10,  20, -20,  30, -30,  40, -40,
             50, -50,  60, -60,  70, -70,  80, -80,
             90, -90, 100,-100, 110,-110, 120,-120,
            130,-130, 140,-140, 150,-150, 160,-160,
            170,-170, 180,-180, 190,-190, 200,-200,
            210,-210, 220,-220, 230,-230, 240,-240,
            250,-250, 260,-260, 270,-270, 280,-280,
            290,-290, 300,-300, 310,-310, 320,-320
        },

        /* Test 3: constant values */
        {
             42, 42, 42, 42, 42, 42, 42, 42,
             42, 42, 42, 42, 42, 42, 42, 42,
             42, 42, 42, 42, 42, 42, 42, 42,
             42, 42, 42, 42, 42, 42, 42, 42,
             42, 42, 42, 42, 42, 42, 42, 42,
             42, 42, 42, 42, 42, 42, 42, 42,
             42, 42, 42, 42, 42, 42, 42, 42,
             42, 42, 42, 42, 42, 42, 42, 42
        },

        /* Test 4: values that exercise the moving window */
        {
             5,  1,  3,  2,  4,  0,  6,  7,
             1,  2,  3,  4,  5,  6,  0,  1,
             2,  3,  4,  5,  6,  7,  8,  0,
             1,  2,  3,  4,  5,  6,  7,  9,
             0,  1,  2,  3,  4,  5,  6,  8,
             1,  2,  3,  4,  5,  6,  7,  0,
             9,  1,  2,  3,  4,  5,  6,  7,
             0,  1,  2,  3,  4,  5,  6,  7
        }
    };

    for (int t = 0; t < 5; t++) {
        int in_data[N_SAMPLES];
        int out_data[N_SAMPLES];
        int golden[N_SAMPLES];

        /* Copy test vector into the input array */
        for (int n = 0; n < N_SAMPLES; n++) {
            in_data[n] = test_vectors[t][n];
        }

        /* Calculate expected result independently */
        reference(in_data, golden);

        /* Run the design under test */
        moving_max(in_data, out_data);

        /* Compare DUT output with reference */
        for (int n = 0; n < N_SAMPLES; n++) {
            if (out_data[n] != golden[n]) {
                printf(
                    "MISMATCH: test %d, sample %d: "
                    "DUT=%d, expected=%d\n",
                    t, n, out_data[n], golden[n]
                );
                errors++;
            }
        }
    }

    if (errors == 0) {
        printf("Test passed !\n");
        return 0;
    }

    printf("Test FAILED: %d errors\n", errors);
    return 1;
}
