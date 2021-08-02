--https://www.va.gov/directory/guide/rpt_fac_list.cfm
--Does not seem to agree on IDs

SELECT    
		  VISN
		, SUBSTRING(FacilityId, CHARINDEX('_',FacilityID)+1, LEN(FacilityID)) AS StationID
		, FacilityName

		, FacilityType
		, UPPER(SUBSTRING(FacilityId, 0, CHARINDEX('_',FacilityID))) AS [Facility_Type_Abbreviated]
	
		--IF this is not NCA, Check for parent/child relationship of facility.
		,CASE WHEN COALESCE(FacilityType,'') <> 'va_cemetery' AND COALESCE(FacilityType,'') <> 'vet_center'THEN  
			  CASE WHEN PATINDEX('%[a-z]%', SUBSTRING(FacilityId, CHARINDEX('_',FacilityID)+1, LEN(FacilityID))) = 0 --If there is no Suffix with letters, we know this is the parent Facility
				   THEN null																						 --So leave it NULL
				   ELSE SUBSTRING( SUBSTRING(FacilityId, CHARINDEX('_',FacilityID)+1, LEN(FacilityID))				 --Since this is a child facility, grab the prefix, the substring after the _ and before the first letter.
								 , 0																				 --This is a little janky, but that is the naming convention and there is no parent/child information in the source JSON
								 , PATINDEX('%[a-z]%', SUBSTRING(FacilityId, CHARINDEX('_',FacilityID)+1, LEN(FacilityID)))
						)
			  END
			  ELSE NULL
		  END AS ParentID
		, Address1
		, Address2
		, City
		, [State]
		, Zip
		, FacilityID

FROM 

OPENROWSET(BULK 'C:\Users\Work\Documents\B3\SWIM\VA-Facilities.json', SINGLE_CLOB) as f
CROSS APPLY OPENJSON(BulkColumn, N'lax $.features')
WITH (
	[Type] VARCHAR(20) N'$.type',
	[Geometry] nvarchar(max) '$.geometry' AS JSON,
	FacilityID VARCHAR(20) N'$.properties.id',
	FacilityName VARCHAR(100) N'$.properties.name',
	FacilityType VARCHAR(20) N'$.properties.facility_type',
	VISN VARCHAR(20) N'$.properties.visn',
	Address1 nvarchar(max) N'$.properties.address.physical.address_1',
	Address2 nvarchar(max) N'$.properties.address.physical.address_2',
	[State] nvarchar(max) N'$.properties.address.physical.state',
	City nvarchar(max) N'$.properties.address.physical.city',
	Zip nvarchar(max) N'$.properties.address.physical.zip',
	[Address] nvarchar(max) N'$.properties.address.physical' AS JSON,
	array_element nvarchar(max) N'$' AS JSON
	)
--WHERE FacilityID LIKE '%402%'

order by FacilityID 
/* reference string manipulations */
--, CHARINDEX('_',FacilityID) AS LocOfUnderscore
--, LEN(FacilityID) AS TotalLength
--, LEN(SUBSTRING(FacilityId, CHARINDEX('_',FacilityID), LEN(FacilityID))) AS LengthAfter_
--,PATINDEX('%[a-z]%', SUBSTRING(FacilityId, CHARINDEX('_',FacilityID)+1, LEN(FacilityID))) AS PatternIndexOfFirstLetter
/*
		, SUBSTRING(SUBSTRING(FacilityId, CHARINDEX('_',FacilityID)+1, LEN(FacilityID)) --AfterUnderscore
					, CASE WHEN PATINDEX('%[a-z]%', SUBSTRING(FacilityId, CHARINDEX('_',FacilityID)+1, LEN(FacilityID))) > 0 --Are there any letters after the numberic ID? Check AfterUnderscore for pat %[a-z]%
						   THEN PATINDEX('%[a-z]%', SUBSTRING(FacilityId, CHARINDEX('_',FacilityID)+1, LEN(FacilityID)))	 --If found give the index
						   ELSE LEN(SUBSTRING(FacilityId, CHARINDEX('_',FacilityID)+1, LEN(FacilityID)))+1					 --If not, return the end.
					  END
					, LEN(SUBSTRING(FacilityId, CHARINDEX('_',FacilityID), LEN(FacilityID))) --Length of checked string to go to end
		) AS ChildFacilitySuffix
*/