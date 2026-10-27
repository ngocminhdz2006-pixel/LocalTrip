package utils;

import org.junit.Assert;
import org.junit.Test;

/**
 * Unit tests verifying core validation, password security, and category UI mapping logic.
 * Can be run via JUnit or directly via `public static void main(String[] args)`.
 */
public class CoreLogicTest {

    // -------------------------------------------------------------------------
    // 1. ValidationUtil Tests
    // -------------------------------------------------------------------------

    @Test
    public void testValidVietnameseNames() {
        Assert.assertTrue("Standard Vietnamese name should be valid",
                ValidationUtil.isValidName("Nguyễn Văn An"));
        Assert.assertTrue("Vietnamese name with accents should be valid",
                ValidationUtil.isValidName("Trần Thị Bích Ngọc"));
        Assert.assertTrue("Vietnamese name should be valid",
                ValidationUtil.isValidName("Lê Đức Thọ"));
        Assert.assertTrue("English name should be valid",
                ValidationUtil.isValidName("John Doe"));
        Assert.assertTrue("Name with apostrophe and hyphen should be valid",
                ValidationUtil.isValidName("Jean-Luc O'Connor"));
    }

    @Test
    public void testInvalidNamesAndXss() {
        Assert.assertFalse("Null name must be invalid",
                ValidationUtil.isValidName(null));
        Assert.assertFalse("Empty name must be invalid",
                ValidationUtil.isValidName(""));
        Assert.assertFalse("Whitespace name must be invalid",
                ValidationUtil.isValidName("    "));
        Assert.assertFalse("Script tag must be rejected",
                ValidationUtil.isValidName("<script>alert(1)</script>"));
        Assert.assertFalse("HTML tag in name must be rejected",
                ValidationUtil.isValidName("User <admin>"));
        Assert.assertFalse("Special characters like quotes/semicolons should be rejected",
                ValidationUtil.isValidName("Robert\"; DROP TABLE Users;--"));
    }

    @Test
    public void testValidTripNames() {
        Assert.assertTrue("Standard trip name should be valid",
                ValidationUtil.isValidTripName("Chuyến đi Đà Lạt 3N2Đ"));
        Assert.assertTrue("English trip name should be valid",
                ValidationUtil.isValidTripName("Summer Vacation in Da Nang"));
        Assert.assertTrue("Trip name with punctuation should be valid",
                ValidationUtil.isValidTripName("Hà Giang Loop 2026!"));
    }

    @Test
    public void testInvalidTripNamesAndXss() {
        Assert.assertFalse("Null trip name must be invalid",
                ValidationUtil.isValidTripName(null));
        Assert.assertFalse("Empty trip name must be invalid",
                ValidationUtil.isValidTripName(""));
        Assert.assertFalse("Whitespace trip name must be invalid",
                ValidationUtil.isValidTripName("   "));
        Assert.assertFalse("Trip name with < tag must be rejected",
                ValidationUtil.isValidTripName("Trip <script>"));
        Assert.assertFalse("Trip name with > tag must be rejected",
                ValidationUtil.isValidTripName("Trip with <img onerror=alert(1)>"));
    }

    // -------------------------------------------------------------------------
    // 2. PasswordValidator & PasswordUtil Tests
    // -------------------------------------------------------------------------

    @Test
    public void testPasswordValidator() {
        Assert.assertNotNull("Null password should fail",
                PasswordValidator.validate(null));
        Assert.assertNotNull("Empty password should fail",
                PasswordValidator.validate(""));
        Assert.assertNotNull("Password under 8 chars should fail",
                PasswordValidator.validate("Ab1!"));
        Assert.assertNotNull("Password without uppercase should fail",
                PasswordValidator.validate("validp@ss1"));
        Assert.assertNotNull("Password without lowercase should fail",
                PasswordValidator.validate("VALIDP@SS1"));
        Assert.assertNotNull("Password without digit should fail",
                PasswordValidator.validate("ValidP@ssword"));
        Assert.assertNotNull("Password without special character should fail",
                PasswordValidator.validate("ValidPass123"));

        Assert.assertNull("Strong password meeting all criteria should pass",
                PasswordValidator.validate("ValidP@ssw0rd!"));
    }

    @Test
    public void testPasswordUtilHashingAndVerification() {
        String rawPassword = "StrongTestPassword#2026";
        String hash = PasswordUtil.hash(rawPassword);

        Assert.assertNotNull("Hash must not be null", hash);
        String[] parts = hash.split(":");
        Assert.assertEquals("Hash format must be iterations:salt:hash", 3, parts.length);
        Assert.assertEquals("Default iterations should be 600000", "600000", parts[0]);

        Assert.assertTrue("Password verify should succeed with correct password",
                PasswordUtil.verify(rawPassword, hash));
        Assert.assertFalse("Password verify should fail with wrong password",
                PasswordUtil.verify("WrongPass#2026", hash));
        Assert.assertFalse("Password verify should fail with null password",
                PasswordUtil.verify(null, hash));
        Assert.assertFalse("Password verify should fail with null hash",
                PasswordUtil.verify(rawPassword, null));

        Assert.assertFalse("Freshly hashed password does not need rehash",
                PasswordUtil.needsRehash(hash));

        String legacyHash = "20000:aabbccdd11223344:eeff001122334455";
        Assert.assertTrue("Legacy hash with lower iterations needs rehash",
                PasswordUtil.needsRehash(legacyHash));
    }

    // -------------------------------------------------------------------------
    // 3. CategoryUi Tests
    // -------------------------------------------------------------------------

    @Test
    public void testCategoryUiCodes() {
        // FOOD
        Assert.assertEquals("🍜", CategoryUi.icon("FOOD"));
        Assert.assertEquals("Food & Dining", CategoryUi.label("FOOD"));

        // CAFE
        Assert.assertEquals("☕", CategoryUi.icon("CAFE"));
        Assert.assertEquals("Cafe & Drinks", CategoryUi.label("CAFE"));

        // SIGHTSEEING
        Assert.assertEquals("🏛️", CategoryUi.icon("SIGHTSEEING"));
        Assert.assertEquals("Sightseeing", CategoryUi.label("SIGHTSEEING"));

        // ENTERTAINMENT
        Assert.assertEquals("🎡", CategoryUi.icon("ENTERTAINMENT"));
        Assert.assertEquals("Entertainment", CategoryUi.label("ENTERTAINMENT"));

        // SHOPPING
        Assert.assertEquals("🛍️", CategoryUi.icon("SHOPPING"));
        Assert.assertEquals("Shopping", CategoryUi.label("SHOPPING"));

        // Fallback / Unknown
        Assert.assertEquals("📍", CategoryUi.icon("UNKNOWN_CATEGORY"));
        Assert.assertEquals("Other", CategoryUi.label("UNKNOWN_CATEGORY"));
        Assert.assertEquals("📍", CategoryUi.icon(null));
        Assert.assertEquals("Other", CategoryUi.label(null));
    }

    @Test
    public void testCategoryUiVietnameseFallbacks() {
        Assert.assertEquals("🍜", CategoryUi.icon("Ăn uống"));
        Assert.assertEquals("☕", CategoryUi.icon("Cà phê"));
        Assert.assertEquals("🏛️", CategoryUi.icon("Tham quan"));
        Assert.assertEquals("🎡", CategoryUi.icon("Giải trí"));
        Assert.assertEquals("🛍️", CategoryUi.icon("Mua sắm"));
    }

    // -------------------------------------------------------------------------
    // Standalone Runner
    // -------------------------------------------------------------------------

    public static void main(String[] args) {
        System.out.println("Running CoreLogicTest standalone runner...");
        CoreLogicTest test = new CoreLogicTest();

        try {
            System.out.print("Testing ValidationUtil name validation... ");
            test.testValidVietnameseNames();
            test.testInvalidNamesAndXss();
            System.out.println("PASSED");

            System.out.print("Testing ValidationUtil trip name validation... ");
            test.testValidTripNames();
            test.testInvalidTripNamesAndXss();
            System.out.println("PASSED");

            System.out.print("Testing PasswordValidator rules... ");
            test.testPasswordValidator();
            System.out.println("PASSED");

            System.out.print("Testing PasswordUtil PBKDF2 hash, verify & rehash... ");
            test.testPasswordUtilHashingAndVerification();
            System.out.println("PASSED");

            System.out.print("Testing CategoryUi icons and labels... ");
            test.testCategoryUiCodes();
            test.testCategoryUiVietnameseFallbacks();
            System.out.println("PASSED");

            System.out.println("\nAll 5 test suites PASSED successfully!");
        } catch (Throwable t) {
            System.err.println("FAILED!");
            t.printStackTrace();
            System.exit(1);
        }
    }
}
