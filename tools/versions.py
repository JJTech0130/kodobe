# Lists of different ADE "versions" we know about
VAR_VER_SUPP_CONFIG_NAMES = [ "ADE 1.7.2", "ADE 2.0.1", "ADE 3.0.1", "ADE 4.0.3", "ADE 4.5.10", "ADE 4.5.11" ]
VAR_VER_SUPP_VERSIONS = [ "ADE WIN 9,0,1131,27", "2.0.1.78765", "3.0.1.91394", "4.0.3.123281", 
                            "com.adobe.adobedigitaleditions.exe v4.5.10.186048", 
                            "com.adobe.adobedigitaleditions.exe v4.5.11.187303" ]
VAR_VER_HOBBES_VERSIONS = [ "9.0.1131.27", "9.3.58046", "10.0.85385", "12.0.123217", "12.5.4.186049", "12.5.4.187298" ]
VAR_VER_OS_IDENTIFIERS = [ "Windows Vista", "Windows Vista", "Windows 8", "Windows 8", "Windows 8", "Windows 8" ]


# "Missing" versions:
# 1.7.1, 2.0, 3.0, 4.0, 4.0.1, 4.0.2, 4.5 to 4.5.9
# 4.5.7.179634

# This is a list of ALL versions we know (and can potentially use if present in a config file).
# Must have the same length / size as the four lists above.
VAR_VER_BUILD_IDS = [ 1131, 78765, 91394, 123281, 186048, 187303 ]
# Build ID 185749 also exists, that's a different (older) variant of 4.5.10. 

# This is a list of versions that can be used for new authorizations:
VAR_VER_ALLOWED_BUILD_IDS_AUTHORIZE = [ 78765, 91394, 123281, 187303 ]

# This is a list of versions to be displayed in the version changer.
VAR_VER_ALLOWED_BUILD_IDS_SWITCH_TO = [ 1131, 78765, 91394, 123281, 187303 ]

# Versions >= this one are using HTTPS
# According to changelogs, this is implemented as of ADE 4.0.1 - no idea what build ID that is.
VAR_VER_NEED_HTTPS_BUILD_ID_LIMIT = 123281

# Versions >= this are using a different order for the XML elements in a FulfillmentNotification.
# This doesn't matter for fulfillment at all, but I want to emulate ADE as accurately as possible.
# Implemented as of ADE 4.0.0, no idea what exact build number that is.
VAR_VER_USE_DIFFERENT_NOTIFICATION_XML_ORDER = 123281

# Default build ID to use - ADE 2.0.1
VAR_VER_DEFAULT_BUILD_ID = 78765

for i in range(0, 6):
    print("{{ name = '{}', version = '{}', hobbes = '{}', os = '{}', build = {} }},".format(
        VAR_VER_SUPP_CONFIG_NAMES[i],
        VAR_VER_SUPP_VERSIONS[i],
        VAR_VER_HOBBES_VERSIONS[i],
        VAR_VER_OS_IDENTIFIERS[i],
        VAR_VER_BUILD_IDS[i]))
