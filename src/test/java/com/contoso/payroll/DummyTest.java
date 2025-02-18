package com.contoso.payroll;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

public class DummyTest {

    private int number;

    @BeforeEach
    void setUp() {
        number = 42;
    }

    @Test
    void testNumberIsCorrect() {
        assertEquals(42, number, "Number should be 42");
    }

    @Test
    void testTrueCondition() {
        assertTrue(5 < 10, "5 is less than 10");
    }
}
