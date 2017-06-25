#import <substrate.h>
#import <UIKit/UIKit.h>

#define PREFERENCE_IDENTIFIER CFSTR("com.tuttarealstep.iunlockpreferences")
#define REAL_PASSCODE_KEY CFSTR("realPasscode")

static NSData *realPasscode;
static bool realPasscodeFailed;
static bool isEnabled = YES;
static bool showAlert = NO;

%hook SBFUserAuthenticationController

	- (bool)_authenticateWithPasscodeData:(id)arg1 outError:(id*)arg2
	{
			NSLog(@"_authenticateWithPasscodeData -----> %@", arg1);

			if(realPasscodeFailed)
			{
				bool result = %orig;
				if (result)
				{
					//Crypt passcode
					realPasscode = arg1;
					CFPreferencesSetAppValue(REAL_PASSCODE_KEY, (CFDataRef)realPasscode, PREFERENCE_IDENTIFIER);

					if (CFPreferencesAppSynchronize(PREFERENCE_IDENTIFIER))
					{
						if(showAlert)
						{
							UIAlertView *alert = [[UIAlertView alloc]
							initWithTitle:@"iUnlock"
							message:@"Updated with the new passcode!"
							delegate:nil
							cancelButtonTitle:@"OK"
							otherButtonTitles:nil];
							[alert show];
						}
						realPasscodeFailed = NO;
					}
				} else {
					if(showAlert)
					{
						UIAlertView *alert = [[UIAlertView alloc]
						initWithTitle:@"iUnlock"
						message:@"It seems like you've changed your passcode. Please unlock your device using the true passcode to reconfigure your device."
						delegate:nil
						cancelButtonTitle:@"OK"
						otherButtonTitles:nil];
						[alert show];
					}
				}

				return result;
			}

			if (realPasscode == NULL)
			{
				bool result = %orig;
				if (result)
				{
					//Crypt passcode
					realPasscode = arg1;
					CFPreferencesSetAppValue(REAL_PASSCODE_KEY, (CFDataRef)realPasscode, PREFERENCE_IDENTIFIER);

					if (CFPreferencesAppSynchronize(PREFERENCE_IDENTIFIER))
					{
						if(showAlert)
						{
							UIAlertView *alert = [[UIAlertView alloc]
							initWithTitle:@"iUnlock"
							message:@"Device configured, you can now use iUnlock!"
							delegate:nil
							cancelButtonTitle:@"OK"
							otherButtonTitles:nil];
							[alert show];
						}
					}
				} else {
					if(showAlert)
					{
						UIAlertView *alert = [[UIAlertView alloc]
						initWithTitle:@"iUnlock"
						message:@"Device not configured, unlock your device for use iUnlock!"
						delegate:nil
						cancelButtonTitle:@"OK"
						otherButtonTitles:nil];
						[alert show];
					}
				}

				return result;
			}


			bool didAnswerCorrectly = NO;
			if (isEnabled)
			{
					didAnswerCorrectly = YES;
					arg1 = realPasscode;
			}

			bool result = %orig(arg1, arg2);
			if (didAnswerCorrectly && !result)
			{
				if(showAlert)
				{
					UIAlertView *alert = [[UIAlertView alloc]
					initWithTitle:@"iUnlock"
					message:@"It seems like you've changed your passcode. Please unlock your device using the true passcode to reconfigure your device."
					delegate:nil
					cancelButtonTitle:@"OK"
					otherButtonTitles:nil];
					[alert show];
				}
				realPasscodeFailed = YES;
			}

			return result;
	}

/*- (long long) _evaluatePasscodeAttempt:(id)arg1 outError:(id*)arg2
	{
		NSLog(@"_evaluatePasscodeAttempt -----> %@", arg1);

		long long prova = %orig;
		NSLog(@"risultato  -----> %lld", prova);

		return prova;
	}*/
%end

static void loadSettings()
{
	CFPreferencesAppSynchronize(PREFERENCE_IDENTIFIER);
	realPasscode = (NSData *)CFBridgingRelease(CFPreferencesCopyAppValue(REAL_PASSCODE_KEY, PREFERENCE_IDENTIFIER));
}

static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	loadSettings();
}

%ctor
{
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChanged, CFSTR("com.tuttarealstep.iunlockpreferences/settingsChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    loadSettings();
}
