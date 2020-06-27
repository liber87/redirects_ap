//<?php
/**
 * redirects_ap
 *
 * Redirect if you are changing alias or parent
 *
 * @category    plugin
 * @internal    @events OnBeforeDocFormSave,OnPageNotFound,onBeforeMoveDocument,onAfterMoveDocument
 * @internal    @modx_category SEO
 * @internal    @properties 
 * @internal    @disabled 0
 * @internal    @installset base
 */
//<?php	
	if (!function_exists('getPath')){
		function getPath($id){	
			global $modx;
			$id = (int) $id;
			$alias = $modx->db->getValue('Select `alias` from '.$modx->getFullTableName('site_content').' where id='.$id);
			$cc = $modx->db->getValue('Select count(*) from '.$modx->getFullTableName('site_content').' where parent='.$id);
			$av = $modx->db->getValue('Select alias_visible from '.$modx->getFullTableName('site_content').' where id='.$id);
			
			if (!$alias) $alias = $id;

			$ids = array();
			while($id!=0){
				$ids[] = $id;
				$id = $modx->db->getValue('Select `parent` from '.$modx->getFullTableName('site_content').' where id='.$id);
			}
			if (count($ids)>1){
				$ids = array_reverse($ids);
				array_pop($ids);	
				$path = $modx->db->getValue('Select GROUP_CONCAT(`alias` SEPARATOR "/") from '.$modx->getFullTableName('site_content').' where id in ('.implode(',',$ids).') and `alias_visible`=1').'/';
			}
						
			if ($cc==0) $suffix = $alias.$modx->config['friendly_url_suffix']; 
			else {				
				if ($av) $suffix = $alias.'/*';
				else $suffix = '/*';
			}
			return str_replace('//','/',$path.$suffix);
		}
	}
	if ($modx->event->name=='OnBeforeDocFormSave')
	{			
		if ($mode=='new') return;
		$alias = $modx->db->getValue('Select alias from '.$modx->getFullTableName('site_content').' where id='.$id);
		if ($alias!=$_POST['alias']){
			$av = $modx->db->getValue('Select alias_visible from '.$modx->getFullTableName('site_content').' where id='.$id);
			if ($av) {
				$old_url = getPath($id);
				
				$new_url = str_replace($alias,$_POST['alias'],$old_url);
				if ($old_url!=$new_url) $modx->db->insert(array('old_url'=>$old_url,'new_url'=>$new_url),$modx->getFullTableName('redirects'));	
			}
		}
	}
	if ($modx->event->name=='onBeforeMoveDocument')
	{		
		$_SESSION['old_url'] = getPath($id_document);		
	}
	if ($modx->event->name=='onAfterMoveDocument')
	{			
		$new = getPath($id_document);		
		if ($new!=$_SESSION['old_url']) 
		{
			$modx->db->insert(array('old_url'=>$_SESSION['old_url'],'new_url'=>$new),$modx->getFullTableName('redirects'));
		}
		unset($_SESSION['old_url']);
	}	
	
	if ($modx->event->name=='OnPageNotFound')
	{
		
		$redirect_url = $modx->db->getValue('Select `new_url` from '.$modx->getFullTableName('redirects').' where `old_url`="'.$modx->db->escape($_REQUEST['q']).'"');
		if (!$redirect_url){
		
		$qa = explode('/',$_REQUEST['q']);	
		$alias = array_pop($qa);
		$path = implode('/',$qa).'/*';
		$new_path = $modx->db->getValue('Select `new_url`from '.$modx->getFullTableName('redirects').' where `old_url`="'.$modx->db->escape($path).'"');			
		if ($new_path) $redirect_url = str_replace('/*','/'.$alias,$new_path);
		}
		if ($redirect_url) 
		{			
			
			$modx->sendRedirect(MODX_BASE_URL.$redirect_url,0,'REDIRECT_HEADER','HTTP/1.1 301 Moved Permanently');		
			exit();
		}
	}	
