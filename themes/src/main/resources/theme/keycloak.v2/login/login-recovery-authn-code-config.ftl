<#import "template.ftl" as layout>
<#import "password-commons.ftl" as passwordCommons>
<@layout.registrationLayout; section>

<#if section = "header">
    ${msg("recovery-code-config-header")}
<#elseif section = "form">
    <!-- warning -->
    <div class="pf-v5-c-alert pf-m-warning pf-m-inline pf-v5-u-mb-md ${properties.kcRecoveryCodesWarning!}" aria-label="Warning alert">
        <div class="pf-v5-c-alert__icon">
            <i class="fas fa-fw fa-bell" aria-hidden="true"></i>
        </div>
        <h4 class="pf-v5-c-alert__title">
            <span class="pf-screen-reader">Warning alert:</span>
            ${msg("recovery-code-config-warning-title")}
        </h4>
        <div class="pf-v5-c-alert__description">
            <p>${msg("recovery-code-config-warning-message")}</p>
        </div>
    </div>

    <div class="pf-v5-c-panel pf-m-raised">
        <div class="pf-v5-c-panel__main">
            <div class="pf-v5-c-panel__main-body">
            <ol id="kc-recovery-codes-list" class="pf-v5-c-list" role="list">
                <#list recoveryAuthnCodesConfigBean.generatedRecoveryAuthnCodesList as code>
                    <li>${code[0..3]}-${code[4..7]}-${code[8..]}</li>
                </#list>
            </ol>
            </div>
        </div>
    </div>

    <!-- actions -->
    <div class="${properties.kcRecoveryCodesActions!}">
        <button id="printRecoveryCodes" class="pf-v5-c-button pf-m-link" type="button" onclick="printRecoveryCodes()">
            <i class="fas fa-print"></i> ${msg("recovery-codes-print")}
        </button>
        <button id="downloadRecoveryCodes" class="pf-v5-c-button pf-m-link" type="button" onclick="downloadRecoveryCodes()">
            <i class="fas fa-download"></i> ${msg("recovery-codes-download")}
        </button>
        <button id="copyRecoveryCodes" class="pf-v5-c-button pf-m-link" type="button" onclick="copyRecoveryCodes()">
            <i class="fas fa-copy"></i> ${msg("recovery-codes-copy")}
        </button>
    </div>

    <!-- confirmation checkbox -->
    <div class="${properties.kcFormOptionsClass!} pf-v5-u-mt-md">
        <input class="${properties.kcCheckInputClass!}" type="checkbox" id="kcRecoveryCodesConfirmationCheck" name="kcRecoveryCodesConfirmationCheck"
        onchange="document.getElementById('saveRecoveryAuthnCodesBtn').disabled = !this.checked;"
        />
        <label for="kcRecoveryCodesConfirmationCheck">${msg("recovery-codes-confirmation-message")}</label>
    </div>

    <form action="${url.loginAction}" class="${properties.kcFormGroupClass!}" id="kc-recovery-codes-settings-form" method="post">
        <input type="hidden" name="generatedRecoveryAuthnCodes" value="${recoveryAuthnCodesConfigBean.generatedRecoveryAuthnCodesAsString}" />
        <input type="hidden" name="generatedAt" value="${recoveryAuthnCodesConfigBean.generatedAt?c}" />
        <input type="hidden" id="userLabel" name="userLabel" value="${msg("recovery-codes-label-default")}" />
        <@passwordCommons.logoutOtherSessions/>

        <#if isAppInitiatedAction??>
            <input type="submit"
            class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}"
            id="saveRecoveryAuthnCodesBtn" value="${msg("recovery-codes-action-complete")}"
            disabled
            />
            <button type="submit"
                class="${properties.kcButtonClass!} ${properties.kcButtonDefaultClass!} ${properties.kcButtonLargeClass!} pf-m-link"
                id="cancelRecoveryAuthnCodesBtn" name="cancel-aia" value="true">${msg("recovery-codes-action-cancel")}
            </button>
        <#else>
            <input type="submit"
            class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}"
            id="saveRecoveryAuthnCodesBtn" value="${msg("recovery-codes-action-complete")}"
            disabled
            />
        </#if>
    </form>

    <script>
        /* copy recovery codes  */
        function copyRecoveryCodes() {
            const tmpTextarea = document.createElement("textarea");
            document.body.appendChild(parseRecoveryCodeList());
            tmpTextarea.select();
            document.execCommand("copy");
            document.body.removeChild(tmpTextarea);
        }

        /* download recovery codes  */
        function formatCurrentDateTime() {
            const dt = new Date();
            const options = {
                month: 'long',
                day: 'numeric',
                year: 'numeric',
                hour: 'numeric',
                minute: 'numeric',
                timeZoneName: 'short'
            };

            return dt.toLocaleString('en-US', options);
        }

        function parseRecoveryCodeList() {
            const recoveryCodes = document.getElementById("kc-recovery-codes-list").getElementsByTagName("li");
            const recoveryCodeList = "";

            for (let i = 0; i < recoveryCodes.length; i++) {
                const recoveryCodeLiElement = recoveryCodes[i].innerText;
                <#noparse>
                recoveryCodeList += `${i}: ${recoveryCodeLiElement}\r\n`;
                </#noparse>
            }

            return recoveryCodeList;
        }

        function buildDownloadContent() {
            const recoveryCodeList = parseRecoveryCodeList();
            const dt = new Date();
            const options = {
                month: 'long',
                day: 'numeric',
                year: 'numeric',
                hour: 'numeric',
                minute: 'numeric',
                timeZoneName: 'short'
            };

            return fileBodyContent =
                "${msg("recovery-codes-download-file-header")}\n\n" +
                recoveryCodeList + "\n" +
                "${msg("recovery-codes-download-file-description")}\n\n" +
                "${msg("recovery-codes-download-file-date")} " + formatCurrentDateTime();
        }

        function setUpDownloadLinkAndDownload(filename, text) {
            const el = document.createElement('a');
            el.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
            el.setAttribute('download', filename);
            el.style.display = 'none';
            document.body.appendChild(el);
            el.click();
            document.body.removeChild(el);
        }

        function downloadRecoveryCodes() {
            setUpDownloadLinkAndDownload('kc-download-recovery-codes.txt', buildDownloadContent());
        }

        /* print recovery codes */
        function buildPrintContent() {
            const recoveryCodeListHTML = document.getElementById('kc-recovery-codes-list').parentNode.innerHTML;
            const styles =
                `@page { size: auto;  margin-top: 0; }
                body { width: 480px; }
                div { font-family: monospace }
                p:first-of-type { margin-top: 48px }`;

            return printFileContent =
                "<html><style>" + styles + "</style><body>" +
                "<title>kc-download-recovery-codes</title>" +
                "<p>${msg("recovery-codes-download-file-header")}</p>" +
                "<div>" + recoveryCodeListHTML + "</div>" +
                "<p>${msg("recovery-codes-download-file-description")}</p>" +
                "<p>${msg("recovery-codes-download-file-date")} " + formatCurrentDateTime() + "</p>" +
                "</body></html>";
        }

        function printRecoveryCodes() {
            const w = window.open();
            w.document.write(buildPrintContent());
            w.print();
            w.close();
        }
    </script>
</#if>
</@layout.registrationLayout>
