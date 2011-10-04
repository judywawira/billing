<%@ include file="/WEB-INF/template/include.jsp" %>
<openmrs:require privilege="Add Bill" otherwise="/login.htm" redirect="/module/billing/main.form" />

<%@ include file="/WEB-INF/template/header.jsp" %>
<script type="text/javascript" src="${pageContext.request.contextPath}/moduleResources/billing/scripts/jquery/jquery-1.4.2.min.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/moduleResources/billing/scripts/jquery/jquery-ui-1.8.2.custom.min.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/moduleResources/billing/scripts/common.js"></script>
<link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/moduleResources/billing/scripts/jquery/css/start/jquery-ui-1.8.2.custom.css" />
<link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/moduleResources/billing/styles/common.css" />
<style>
	.detailDiv{z-index: 100;border:1px solid black; display: none; position: absolute; background-color:#CFE7FF;padding:3px;}
</style>
<c:forEach items="${errors.allErrors}" var="error">
	<span class="error"><spring:message code="${error.defaultMessage}" text="${error.defaultMessage}"/></span><
</c:forEach>
<script>
	jQuery(document).ready(function(){
		jQuery(".udiv").hover(
				function(){
					jQuery(this).children("div.detailDiv:first").show();
				}
				,function(){
					jQuery(this).children("div.detailDiv:first").hide();
				});
	});
</script>
<c:if test="${not empty listAmbulance }">
<div id="tabs">
<ul>
	<li><a href="#fragment" style="color: white"><span>List Ambulances</span></a></li>
</ul>
<div id="fragment">
	<c:forEach items="${listAmbulance}" var="ambulance">
		<div id="ambulance_${ambulance.ambulanceId}"   class="udiv boxNormal" onclick="addToBill('${ambulance.ambulanceId}', '${ambulance.name}')">
			${ambulance.name}
		</div>
	</c:forEach>
</div>
</div>
</c:if>

<script type="text/javascript">
	function addToBill(ambulanceId, name) {
		var colorSelected = "rgb(170, 255, 170)";
		if(document.getElementById("billItem_"+ambulanceId) != null){
			deleteInput(ambulanceId, name);
		}
		else
		{
			var deleteString = 'deleteInput(\"'+ambulanceId+'\")';

	       	var htmlText =  " "
	       	+"<input  name='ambulanceIds' type='checkbox' value='"+ambulanceId+"' style='display:none; visibility:hidden;' checked='true'> "
	       	+"<input  type='text' size='25' id='"+ambulanceId+"_name' value='"+name+"'  readonly='readonly'/>"
	    	+"<input  type='text' name='"+ambulanceId+"_numOfTrip' id='"+ambulanceId+"_qty'  value='0' onblur='checkNum(this.value)' class='numberField' size='5'/>&nbsp;"
	    	+"<input  type='text' name='"+ambulanceId+"_amount' id='"+ambulanceId+"_amount'  value='0' onblur='updatePrice("+ambulanceId+");' size='5' class='moneyField'  />"
	    	+"<input  type='hidden' id='"+ambulanceId+"_tmpamount'   value='0' />"
	      	+"<a style='color:red' href='#' onclick='"+deleteString+"' >&nbsp;[X]</a>";
	       	
	        var newElement = document.createElement('div');
	        newElement.setAttribute("id", "billItem_"+ambulanceId);
		        
		 	newElement.innerHTML = htmlText;

	        var fieldsArea = document.getElementById('extra');
			fieldsArea.appendChild(newElement);
			document.getElementById("ambulance_"+ambulanceId).style.backgroundColor=colorSelected; 
			var serName = jQuery("#"+ambulanceId+"_name").val();
			serName = serName.replace("#","\'");
			jQuery("#"+ambulanceId+"_name").val(serName);
		}
	}
		function deleteInput(ambulanceId ) {
			var parentDiv = 'extra';
		 	if (document.getElementById("billItem_"+ambulanceId)) {     
		        var child = document.getElementById("billItem_"+ambulanceId);
		        var parent = document.getElementById(parentDiv);
		        var removevalue = parseFloat(document.getElementById(ambulanceId+'_amount').value);
		        parent.removeChild(child);
		        var totalprice = parseFloat(document.getElementById('totalprice').value);
		        document.getElementById('totalprice').value = totalprice  - removevalue;
		        document.getElementById("ambulance_"+ambulanceId).style.backgroundColor="#FCCFFF";
		   }
		   else {
		        alert("Element has already been removed or does not exist.");
		        return false;
		   }
		}

		function checkNum(value){
			var objRegExp  = /^ *[0-9]+ *$/;
			if( !objRegExp.test(value) || value=='' || value <=0){
					alert("Please enter valid number of trips!!!");
			}
		}

		function updatePrice(ambulanceId){
			var amount = document.getElementById(ambulanceId+'_amount').value;
			var objRegExp  = /^\d+(\.\d+)?$/;
			if( !objRegExp.test(amount) || amount=='' || amount <=0){
					alert("Please enter valid amount!!!");
					var ele = document.getElementById(ambulanceId+'_amount');
					setTimeout(function(){ele.focus()}, 10);
			}else{		
				var oldValue = parseFloat(document.getElementById(ambulanceId+'_tmpamount').value);
				amount = parseFloat(amount);
				var total = parseFloat(document.getElementById('totalprice').value);
				document.getElementById('totalprice').value = ( total - oldValue ) + amount;
				document.getElementById(ambulanceId+'_tmpamount').value = amount;
			}
		}

		function validateForm(){
			$('#totalprice').focus();
			var okNum = true;
			var okMoney = true;
			var objRegExp  = /^ *[0-9]+ *$/;
			jQuery(".numberField").each(function(){
				var qty = jQuery(this).val();
				if( !objRegExp.test(qty) || qty=='' || qty <=0){
					okNum = false;
				}
			});
			var moneyReg = /^\d+(\.\d+)?$/;
			jQuery(".moneyField").each(function(){
				var val = jQuery(this).val();
				if( !moneyReg.test(val) || val=='' || val <=0){
					okMoney = false;
				}
			});
			if( !okNum ) {
				alert("Please enter valid number of trip!");
			}else if(! jQuery("input[type='checkbox']","div#extra").length ) {
				alert("Please select item for billing");
			}else if( !okMoney ){
				alert("Please enter valid amount!");
			}else{
				jQuery("#billForm").submit()
			}
		}
</script>

		<!-- Right side div for bill collection -->
		<div id="billDiv">
		<form method="POST" id="billForm" action="addAmbulanceBill.form" onsubmit="return false">
		<div> <input type="button" id="subm" onclick="validateForm()" name="subm" value="<spring:message code='billing.bill.save'/>" />
		<input type="button" value="<spring:message code='general.cancel'/>" onclick="javascript:window.location.href='ambulanceBill.list?driverId=${driverId}'" />
		<input type="button" id="toogleBillBtn" value="-" onclick="toogleBill(this);" class="min" style="float: right" /></div>
		<div id="total" style="background: #f6f6f6; border: 1px #808080 solid; padding: 0.3em;margin:0.3em 0em; width: 100%;">
		<input type='text' size='25' value='Total:' />&nbsp; 
		<input type='text' size='3' value='' readonly="readonly" />&nbsp;
		<input type='text' id='totalprice' name='totalprice' size='5' value='0' readonly="readonly" />&nbsp; <b>
		</div>

		<input type="hidden" name="driverId" value="${driverId}"> 
		<input type="hidden" id="serviceCount" name="serviceCount" value="0">

		<div id="extra" style="background: #f6f6f6; border: 1px #808080 solid; padding: 0.3em;margin:0.3em 0em; width: 100%;">
		<input type='text' size='25' value='Ambulance Name' readonly='readonly' />&nbsp; 
		<input type='text' size="5" value='No. Trip' readonly="readonly" />&nbsp;
		<input type='text' size='5' value='Amount' readonly="readonly" />&nbsp;</b>
		<hr/>
		</div>
	
		
		</form>
		</div>
	
<%@ include file="/WEB-INF/template/footer.jsp" %> 