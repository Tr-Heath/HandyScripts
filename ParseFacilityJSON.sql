--https://www.va.gov/directory/guide/rpt_fac_list.cfm
--Does not seem to agree on IDs

SELECT    FacilityID
		, FacilityName
		, FacilityType
		, Visn
		, CHARINDEX('_',FacilityID) AS LocOfUnderscore
		, LEN(FacilityID) AS TotalLength
		, LEN(SUBSTRING(FacilityId, CHARINDEX('_',FacilityID), LEN(FacilityID))) AS LengthAfter_
		, LEN(FacilityID)-LEN(SUBSTRING(FacilityId, CHARINDEX('_',FacilityID)+1, LEN(FacilityID)))
		, SUBSTRING(FacilityId, CHARINDEX('_',FacilityID)+1, LEN(FacilityID)) AS AfterUnderscore
		, SUBSTRING(FacilityId, 0, CHARINDEX('_',FacilityID)) AS BeforeUnderscore
		
		
		, SUBSTRING(SUBSTRING(FacilityId, CHARINDEX('_',FacilityID)+1, LEN(FacilityID)) --AfterUnderscore
					, CASE WHEN PATINDEX('%[a-z]%', SUBSTRING(FacilityId, CHARINDEX('_',FacilityID)+1, LEN(FacilityID))) > 0 --Are there any letters after the numberic ID? Check AfterUnderscore for pat %[a-z]%
						   THEN PATINDEX('%[a-z]%', SUBSTRING(FacilityId, CHARINDEX('_',FacilityID)+1, LEN(FacilityID)))	 --If found give the index
						   ELSE LEN(SUBSTRING(FacilityId, CHARINDEX('_',FacilityID)+1, LEN(FacilityID)))+1					 --If not, return the end.
					  END
					, LEN(SUBSTRING(FacilityId, CHARINDEX('_',FacilityID), LEN(FacilityID))) --Length of checked string to go to end
		) AS ChildFacilitySuffix
							 

		,PATINDEX('%[a-z]%', SUBSTRING(FacilityId, CHARINDEX('_',FacilityID)+1, LEN(FacilityID))) AS PatternIndexOfFirstLetter
		--, LEN(SUBSTRING(FacilityID,PATINDEX('%[a-z]%',FacilityID),0))
		--, SUBSTRING(FacilityID,CHARINDEX('_',FacilityID),LEN(FacilityId)-LEN(SUBSTRING(FacilityID,PATINDEX('%[a-z]%',FacilityID),0)
		--, [Address]
FROM 

OPENROWSET(BULK 'C:\Users\Work\Documents\B3\SWIM\VA-Facilities.json', SINGLE_CLOB) as f
CROSS APPLY OPENJSON(BulkColumn, N'lax $.features')
WITH (
	[Type] VARCHAR(20) N'$.type',
	[Geometry] nvarchar(max) '$.geometry' AS JSON,
	FacilityID VARCHAR(20) N'$.properties.id',
	FacilityName VARCHAR(100) N'$.properties.name',
	FacilityType VARCHAR(20) N'$.properties.facility_type',
	Visn VARCHAR(20) N'$.properties.visn',
	[Address] nvarchar(max) N'$.properties.address' AS JSON,
	array_element nvarchar(max) N'$' AS JSON
	)
WHERE FacilityID LIKE '%554%'
ORDER BY FacilityID