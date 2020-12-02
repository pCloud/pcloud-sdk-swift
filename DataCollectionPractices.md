### Data collection practices for pCloud's Swift SDK

Type of data | Collected? | Used for tracking? | Context
--- | --- | --- | ---
**Contact info** |
Name | No | No
Email address | Yes | No | The SDK itself does not use the user's email address. However, the user may need to enter their email address during the OAuth flow. The pCloud service stores it and uses it for authentication and communication with the end user.
Phone number | No | No
Physical address | No | No
Other user contact info | No | No
**Health and fitness** |
Health | No | No
Fitness | No | No
**Financial info** |
Payment info | No | No
Credit info | No | No
Other financial info | No | No
**Location** |
Precise location | No | No
Coarse location | No | No
**Sensitive info** |
Sensitive info | No | No
**Contacts** |
Contacts | No | No
**User content** |
Emails or text messages | No | No
Photos or videos | No | No
Audio data | No | No
Gameplay content | No | No
Customer support | No | No
Other user content | No | No
**Browsing history** |
Browsing history | No | No
**Search history** |
Search history | No | No
**Identifiers** |
User ID | No | Yes | An identifier assigned to a user by the pCloud service upon account creation. Used by the SDK to keep track of the currently authenticated user. It is provided by the pCloud API and stored in the device's keychain. The pCloud API will also use it to track user behaviour in order to improve the performance and functionality of the service.
Device ID | No | No
**Purchases** |
Purchase history | No | No
**Usage data** |
Product interaction | No | No
Advertising data | No | No
Other usage data | No | No
**Diagnostics** |
Crash data | No | No
Performance data | No | No
Other diagnostic data | No | No
**Other data** |
Other data types | No | No


