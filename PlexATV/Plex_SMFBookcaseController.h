//
//  Plex_SMFBookcaseController.h
//  SMFramework
//
//  Created by Chris Jensen on 2/26/11.
//

#import <Backrow/Backrow.h>
#import "PlexMediaShelfView.h"

@class Plex_SMFBookcaseController;
/**
 *Datasource protocol for the Plex_SMFBookcaseController
 */
@protocol Plex_SMFBookcaseControllerDatasource
/**
 *@param bookcaseController the bookcase asking for the header
 *@return a string containing the title for the controller
 */
- (NSString *)headerTitleForBookcaseController:(Plex_SMFBookcaseController *)bookcaseController;
/**
 *@param bookcaseController the bookcase
 *@return the number of shelves on your bookcase
 */
- (NSInteger)numberOfShelfsInBookcaseController:(Plex_SMFBookcaseController *)bookcaseController;
/**
 *@param bookcaseController the bookcase
 *@param index the index of the shelf for which to return a datastore provider
 *@return the datastoreprovider with the posters
 *
 */
- (BRPhotoDataStoreProvider *)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController datastoreProviderForShelfAtIndex:(NSInteger)index;
@optional
/**
 *@param bookcaseController the bookcase
 *@return an image to be displayed in the top right corner
 */
- (BRImage *)headerIconForBookcaseController:(Plex_SMFBookcaseController *)bookcaseController;
/**
 *@param bookcaseController the bookcase
 *@param index the index of the shelf for which to return a title
 *@return the title for the shelf at index: index
 */
- (NSString *)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController titleForShelfAtIndex:(NSInteger)index;
@end

@protocol Plex_SMFBookcaseControllerDelegate
-(BOOL)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController allowSelectionForShelf:(PlexMediaShelfView *)shelfControl atIndex:(NSInteger)index;
@optional
-(void)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController selectionWillOccurInShelf:(PlexMediaShelfView *)shelfControl atIndex:(NSInteger)index;
-(void)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController selectionDidOccurInShelf:(PlexMediaShelfView *)shelfControl atIndex:(NSInteger)index;
-(void)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController shelf:(PlexMediaShelfView *)shelfControl noLongerFocusedAtIndex:(NSInteger)index;
-(void)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController shelf:(PlexMediaShelfView *)shelfControl focusedAtIndex:(NSInteger)index;
@end

@interface Plex_SMFBookcaseController : BRController {
	NSObject<Plex_SMFBookcaseControllerDatasource> *datasource;
    NSObject<Plex_SMFBookcaseControllerDelegate> *delegate;
	
@private
	//datasource variables
	NSInteger numberOfShelfControls;
	NSMutableArray *_shelfTitles;
    
	//delegate variables
    int focusedShelfIndex;
    PlexMediaShelfView *focusedShelf;
	
	//ui controls
	NSMutableArray *_shelfControls;
	BRPanelControl *_panelControl;
}
@property (retain) NSObject <Plex_SMFBookcaseControllerDatasource> *datasource;
@property (retain) NSObject <Plex_SMFBookcaseControllerDelegate> *delegate;
- (void)rebuildBookcase;
- (void)refreshShelves;
- (void)refreshShelfAtIndex:(NSInteger)index;

@end

