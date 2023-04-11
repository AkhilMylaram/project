SELECT edd.id, edd.trg_ebs_version, edd.src_ebs_version, edd.parser_version, edd.parse_startdate, edd.parse_enddate, COUNT(1) 
  FROM ebs_dmcr_dnh edd, ebs_dmcr_dnh_object eddo
 WHERE eddo.ebs_dmcr_dnh_id = edd.id
 GROUP BY edd.id, edd.trg_ebs_version, edd.src_ebs_version, edd.parser_version, edd.parse_startdate, edd.parse_enddate
 ORDER BY edd.trg_ebs_version, edd.src_ebs_version, edd.parser_version, edd.parse_startdate, edd.parse_enddate;

SELECT edd.id, edd.trg_ebs_version, edd.src_ebs_version, edd.parser_version, edd.parse_startdate, edd.parse_enddate, COUNT(1) 
  FROM ebs_fcr_dnh edd, ebs_fcr_dnh_item eddo
 WHERE eddo.ebs_fcr_dnh_id = edd.id
 GROUP BY edd.id, edd.trg_ebs_version, edd.src_ebs_version, edd.parser_version, edd.parse_startdate, edd.parse_enddate
 ORDER BY edd.trg_ebs_version, edd.src_ebs_version, edd.parser_version, edd.parse_startdate, edd.parse_enddate;

SELECT edd.id, edd.trg_ebs_version, edd.src_ebs_version, edd.parser_version, edd.parse_startdate, edd.parse_enddate, COUNT(1) 
  FROM ebs_sdcr_dnh edd, ebs_sdcr_dnh_item eddo
 WHERE eddo.ebs_sdcr_dnh_id = edd.id
 GROUP BY edd.id, edd.trg_ebs_version, edd.src_ebs_version, edd.parser_version, edd.parse_startdate, edd.parse_enddate
 ORDER BY edd.trg_ebs_version, edd.src_ebs_version, edd.parser_version, edd.parse_startdate, edd.parse_enddate;

