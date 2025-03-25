/**
    javascript
    Copy code
    const usernameRegExp = /^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@#$%^&+=!]).+$/;
    Explanation of the RegExp:

    ^: Matches the start of the string.
    (?=.*[A-Z]): Positive lookahead assertion that checks for at least one uppercase letter ([A-Z]).
    (?=.*[a-z]): Positive lookahead assertion that checks for at least one lowercase letter ([a-z]).
    (?=.*\d): Positive lookahead assertion that checks for at least one numeric digit (\d).
    (?=.*[@#$%^&+=!]): Positive lookahead assertion that checks for at least one special character from the given set ([@#$%^&+=!]). You can modify this set to include other special characters as needed.
    .+: Matches one or more of any characters (to ensure the username contains characters other than just the required uppercase, lowercase, numeric, and special characters).
    $: Matches the end of the string.
 */
export const passwordRegexp = new RegExp(/^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@#$%^&+=!]).+$/)

/**
    javascript
    Copy code
    const usernameRegExp = /^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).+$/;
    Explanation of the RegExp:

    ^: Matches the start of the string.
    (?=.*[A-Z]): Positive lookahead assertion that checks for at least one uppercase letter ([A-Z]).
    (?=.*[a-z]): Positive lookahead assertion that checks for at least one lowercase letter ([a-z]).
    (?=.*\d): Positive lookahead assertion that checks for at least one numeric digit (\d).
    .+: Matches one or more of any characters (to ensure the username contains characters other than just the required uppercase, lowercase, and numeric characters).
    $: Matches the end of the string.
 */
export const usernameRegexp = new RegExp(/^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).+$/);
