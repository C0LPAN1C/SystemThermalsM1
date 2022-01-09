//
//  AppDelegate.m
//  SystemThermals
//
//  Created by Apollo SOFTWARE on 2/1/21.
//

#import "AppDelegate.h"


@interface AppDelegate ()
@property (strong, nonatomic) M1Wrapper *m1smc;
@end

@implementation AppDelegate

int t_UNIT = CELC;


-(id)init
{
    self = [super init];
    if(self)
    {
        _m1smc = [M1Wrapper sharedWrapper];
        t_UNIT = CELC;
    }

    return self;
}

- (NSColor *) get_temp_colour:(float) t
{
    NSColor *tempColour = [NSColor textColor];
    
    if (t < TJ_WARN1)
    {
        tempColour = [NSColor greenColor];
    }
    if (t >= TJ_WARN1)
    {
        tempColour = [NSColor yellowColor];
    }
    if (t >= TJ_WARN2)
    {
        tempColour = [NSColor orangeColor];
    }

    if (t >= TJ_WARN3 || t >= TJ_MAX)
    {
        tempColour = [NSColor redColor];
    }
    return tempColour;
}

- (NSString *) get_cpu_temperature
{
    return [_m1smc get_temp_values];
}

- (float) get_cpu_temp
{
    return [_m1smc get_temp_float];
}

-(void) open
{
    
}

- (void)showMenu {
 
    NSMenuItem* menuBarItem = [[NSMenuItem alloc]
                            initWithTitle:@"Custom" action:NULL keyEquivalent:@""];
    // title localization is omitted for compactness
    _menu = [[NSMenu alloc] initWithTitle:@"Custom"];
    [menuBarItem setSubmenu:_menu];
    [[NSApp mainMenu] insertItem:menuBarItem atIndex:3];
}

- (void)exitApp{
    NSLog(@"Quitting App");
    exit(0);
}

- (IBAction)selectDefault:(id)sender {
    [self selectUnit:NONE];
}
- (IBAction)selectCelcius:(id)sender {
    [self selectUnit:CELC];
}
- (IBAction)selectFahrenheit:(id)sender {
    [self selectUnit:FAREN];
}
- (IBAction)selectKelvin:(id)sender {
    [self selectUnit:KELV];
}

- (void)selectUnit:(int) unit{
    NSLog(@"selecUnit");
    t_UNIT = unit;
    [self update_temp];
}

- (void)selectUnit{
    NSLog(@"selecUnit");
    if (t_UNIT == NONE)
        t_UNIT = CELC;
    else if (t_UNIT == FAREN)
        t_UNIT = KELV;
    else if (t_UNIT == KELV)
        t_UNIT = NONE;
    else if (t_UNIT == CELC)
        t_UNIT = FAREN;
    [self update_temp];
}

-(void)buttonClick:(id)sender {
    NSEvent* event;

    event = [NSEvent mouseEventWithType:NSEventTypeLeftMouseDown
                               location:[NSEvent mouseLocation]
                             modifierFlags:[event modifierFlags]
                                 timestamp:CFAbsoluteTimeGetCurrent()
                              windowNumber:[event windowNumber]
                                   context:nil
                               eventNumber:[event eventNumber]
                                clickCount:[event clickCount]
                                  pressure:[event pressure]];
    
    [NSMenu popUpContextMenu:_menu withEvent:event forView:(NSButton *)sender];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [NSApp setActivationPolicy: NSApplicationActivationPolicyProhibited];
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _menu = [NSApp mainMenu];
    _statusItem.button.action = @selector(buttonClick:);
    _statusItem.button.target = self;
    _statusBar = [NSStatusBar systemStatusBar];

    [_statusBar statusItemWithLength:3];
    // The text that will be shown in the menu bar
    [self update_temp];
    
    [self performSelector:@selector(mainthread_dotask) withObject:nil afterDelay:DELAY_T];
    
}

- (void) mainthread_dotask
{
    [self update_temp];
    [self performSelector:@selector(mainthread_dotask) withObject:nil afterDelay:DELAY_T];
}

- (float) get_temp_var:(float) t {

    if (t_UNIT == CELC)
        return t;
    if (t_UNIT == KELV)
        return t + 273.15f;
    return (t * 9.0f/5.0f) + 32.0f; //default
}

- (NSString *) get_temp_label {

    if (t_UNIT == KELV)
        return @"K";
    if (t_UNIT == FAREN)
        return @"F";
    if (t_UNIT == NONE)
        return @"";
    return @"C";
}

- (void) update_temp
{
    float t = [self get_cpu_temp];
    NSDictionary *titleAttributes = [NSDictionary dictionaryWithObject:[self get_temp_colour:t] forKey:NSForegroundColorAttributeName];

    NSAttributedString* colouredTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.1f°%@",[self get_temp_var:t],[self get_temp_label]] attributes:titleAttributes];

    _statusItem.button.attributedTitle = colouredTitle;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [_m1smc m1Close];
}


@end
