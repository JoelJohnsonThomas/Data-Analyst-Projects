--cleaning data in sql queries

SELECT *
  FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]



  --Standaize Date Format

  SELECT SaleDateConverted,CONVERT(Date,SaleDate)
  FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]

  Update [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  SET SaleDate = CONVERT(Date,SaleDate)

  alter table [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  add SaleDateConverted Date;

  Update [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  set SaleDateConverted = CONVERT(Date,SaleDate)



  --Populate Property Address Data

    SELECT *
  FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning] 
  --where PropertyAddress
  order by ParcelID


  SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
  FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning] a
  join [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning] b
  on a.ParcelID=b.ParcelID
  and a.UniqueID<>b.UniqueID
  where a.PropertyAddress is null

  --replacing null with the populated address
  update a
  set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
   FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning] a
  join [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning] b
  on a.ParcelID=b.ParcelID
  and a.UniqueID<>b.UniqueID
  where a.PropertyAddress is null

  --Breaking out address into individual columns (address,city,state)

  select PropertyAddress
FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]

SELECT SUBSTRING(PropertyAddress,1,charindex(',', PropertyAddress)-1) as Address

,SUBSTRING(PropertyAddress,charindex(',', PropertyAddress)+1,len(PropertyAddress)) as Address


FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]

select PropertyAddress 

FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]

 alter table [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  add PropertySplitAddress Nvarchar(255);

  Update [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  set PropertySplitAddress = SUBSTRING(PropertyAddress,1,charindex(',', PropertyAddress)-1)

   alter table [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  add PropertySplitCity Nvarchar(255);

  Update [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  set PropertySplitCity = SUBSTRING(PropertyAddress,charindex(',', PropertyAddress)+1,len(PropertyAddress))

	  select * from [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]


  
  select OwnerAddress from [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]

  select parsename(replace(OwnerAddress,',','.'),3),
  parsename(replace(OwnerAddress,',','.'),2),
  parsename(replace(OwnerAddress,',','.'),1)
  
  from [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]


  alter table [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  add OwnerSplitAddress Nvarchar(255);

  Update [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3)

   alter table [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  add OwnerSplitCity Nvarchar(255);

  Update [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2)

  alter table [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  add OwnerSplitState Nvarchar(255);

  Update [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  set OwnerSplitState =  parsename(replace(OwnerAddress,',','.'),1)

  select * from [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  


  --change Y and N to Yes and No in "Sold as Vacant" field

  select distinct(SoldAsVacant),count(SoldAsVacant) from[PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  group by SoldAsVacant
  order by SoldAsVacant

  select distinct(SoldAsVacant),count(SoldAsVacant) from[PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  group by SoldAsVacant
  order by 2

  select distinct(SoldAsVacant),count(SoldAsVacant) from[PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  group by SoldAsVacant
  order by 2
  


  select SoldAsVacant,
   CASE WHEN SoldAsVacant =1 THEN 'Yes'
		WHEN SoldAsVacant =0 THEN 'No'
		ELSE CAST(SoldAsVacant as varchar) 
		END 
  from[PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
 

  alter table [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  add SoldVacantStatus varchar(10) 

  update [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  set SoldVacantStatus=  CASE WHEN SoldAsVacant =1 THEN 'Yes'
		WHEN SoldAsVacant =0 THEN 'No'
		ELSE CAST(SoldAsVacant as varchar) 
		END 

select* from [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
select distinct(SoldVacantStatus),count(SoldVacantStatus) from [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning] group by SoldVacantStatus order by 2

select * from [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]


-- 1.0 remove duplicates
 
  select * from [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]

With RowNumCTE as( 
  select *,ROW_NUMBER() over(partition by ParcelID,PropertyAddress,
  SalePrice,SaleDate,LegalReference order by UniqueID)row_num
  from [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  --order by ParcelID
  )
  SELECT * FROM RowNumCTE where row_num>1 order by PropertyAddress


  --1.1 deleting the duplicates

  With RowNumCTE as( 
  select *,ROW_NUMBER() over(partition by ParcelID,PropertyAddress,
  SalePrice,SaleDate,LegalReference order by UniqueID)row_num
  from [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  --order by ParcelID
  )
  delete FROM RowNumCTE where row_num>1 




  --delete unused columns

  
  select * from [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]



  alter table [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  drop column OwnerAddress, TaxDistrict, PropertyAddress

  
  alter table [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  drop column SaleDate

  
  alter table [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
  drop column SoldAsVacant

  EXEC sp_rename 'PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning].SoldVacantStatus', 'SoldAsVacant', 'COLUMN';

  -- Rename column 'oldName' to 'newName' in the 'Employees' table
EXEC sp_rename 'Employees.oldName', 'newName', 'COLUMN';
