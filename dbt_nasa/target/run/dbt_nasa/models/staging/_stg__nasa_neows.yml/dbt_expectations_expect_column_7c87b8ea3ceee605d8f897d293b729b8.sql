
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  with relation_columns as (

        
        select
            cast('ID' as TEXT) as relation_column,
            cast('VARCHAR' as TEXT) as relation_column_type
        union all
        
        select
            cast('NEO_REFERENCE_ID' as TEXT) as relation_column,
            cast('VARCHAR' as TEXT) as relation_column_type
        union all
        
        select
            cast('NAME' as TEXT) as relation_column,
            cast('VARCHAR' as TEXT) as relation_column_type
        union all
        
        select
            cast('ABSOLUTE_MAGNITUDE_H' as TEXT) as relation_column,
            cast('FLOAT' as TEXT) as relation_column_type
        union all
        
        select
            cast('IS_POTENTIALLY_HAZARDOUS_ASTEROID' as TEXT) as relation_column,
            cast('BOOLEAN' as TEXT) as relation_column_type
        union all
        
        select
            cast('ESTIMATED_DIAMETER_MIN' as TEXT) as relation_column,
            cast('FLOAT' as TEXT) as relation_column_type
        union all
        
        select
            cast('ESTIMATED_DIAMETER_MAX' as TEXT) as relation_column,
            cast('FLOAT' as TEXT) as relation_column_type
        
        
    ),
    test_data as (

        select
            *
        from
            relation_columns
        where
            relation_column = 'IS_POTENTIALLY_HAZARDOUS_ASTEROID'
            and
            relation_column_type not in ('BOOLEAN')

    )
    select *
    from test_data
  
  
      
    ) dbt_internal_test