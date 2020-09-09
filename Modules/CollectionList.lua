local addonName, addon = ...
addon = LibStub("AceAddon-3.0"):GetAddon(addonName)

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local CollectionList = {}
addon.CollectionList = CollectionList

function CollectionList:BuildCollectionList()
	local list = {}
	for visualID, _ in pairs(addon.chardb.profile.collectionList["item"]) do 
		local sources = C_TransmogCollection.GetAppearanceSources(visualID)

	local sourceInfo = C_TransmogCollection.GetSourceInfo(sources[1].sourceID)
	sourceInfo.isUseable = true
		tinsert(list, sourceInfo)
	end

	return list
end


--Needs to to take account of variant
function CollectionList:UpdateList(type, typeID, add)
	typeID = tonumber(typeID)
	if not typeID then return end
	local addSet = false
	local setName, setInfo, itemModID
	if type == "item" then --TypeID is visualID
			addon.chardb.profile.collectionList[type][typeID] = add or nil
			if WardrobeCollectionFrame.ItemsCollectionFrame:IsShown() then 
				WardrobeCollectionFrame.ItemsCollectionFrame:UpdateItems()
				print(add and L["Appearance added."] or L["Appearance removed."] )
			end
			return addon.chardb.profile.collectionList[type][typeID]
	else
			local sources
			if type == "set" then 
				sources = C_TransmogSets.GetSetSources(typeID)
				setName = C_TransmogSets.GetSetInfo(typeID).name
			else 
				setInfo = addon.GetSetInfo(typeID)
				sources = addon.GetSetsources(typeID)
				setName = "name"
				itemModID = setInfo.mod
			end

			addon.chardb.profile.collectionList[type][typeID] = (add and {}) or nil

			for sourceID, isCollected in pairs(sources) do

				local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
				local visualID = C_TransmogCollection.GetItemInfo(sourceInfo.itemID, itemModID)--(type == "set" and sourceInfo.visualID) or addon.GetItemSource(sourceID, setInfo.mod)

				if add then
					addon.chardb.profile.collectionList[type][typeID][visualID] = (add and not isCollected and add)
				end

				addSet = self:UpdateList("item", visualID, (add and not isCollected) or nil)	
			end

			if type == "set" then 
				WardrobeCollectionFrame.SetsCollectionFrame:OnSearchUpdate()
				WardrobeCollectionFrame.SetsTransmogFrame:OnSearchUpdate()
			else
				BW_SetsTransmogFrame:OnSearchUpdate()
				BW_SetsCollectionFrame:OnSearchUpdate()
			end

			--print( addSet and L["%s: Uncollected items added"]:format(setName) or L["No new appearces needed."])
			return addSet
	end	
end


BetterWardrobeSetsCollectionListMixin = {}
function BetterWardrobeSetsCollectionListMixin:Toggle(toggleState)
	local atTransmogrifier = WardrobeFrame_IsAtTransmogrifier()
	WardrobeCollectionFrame.ItemsCollectionFrame:SetActiveSlot("HEADSLOT", LE_TRANSMOG_TYPE_APPEARANCE)
	WardrobeCollectionFrame.ItemsCollectionFrame:RefreshVisualsList();
	WardrobeCollectionFrame.ItemsCollectionFrame:UpdateItems()
	WardrobeCollectionFrame.ItemsCollectionFrame.SlotsFrame:SetShown(not toggleState and not atTransmogrifier)
	WardrobeCollectionFrameWeaponDropDown:SetShown(not toggleState)
	self.CollectionListTitle:SetShown(toggleState)
end


function BetterWardrobeSetsCollectionListMixin:SetTitle()
	self.CollectionListTitle.Name:SetText(L["Collection List"])
end