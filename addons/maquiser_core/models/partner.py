from odoo import models, fields

class ResPartner(models.Model):
    _inherit = 'res.partner'

    # Campos existentes
    tipo_documento = fields.Selection(
        [('nit', 'NIT'), ('ci', 'CI')], 
        string='Tipo de Documento'
    )
    numero_documento = fields.Char(string='Número de Documento')
    empresa_asociada = fields.Char(string='Empresa Asociada')
    es_cliente_uniformes = fields.Boolean(string='Es Cliente de Uniformes')
    es_proveedor_textil = fields.Boolean(string='Es Proveedor Textil')
    
    # Campo corregido con relación explícita
    categoria_textil = fields.Many2many(
        'res.partner.category',
        relation='res_partner_category_textil_rel',
        column1='partner_id',
        column2='category_id',
        string='Categorías Textiles'
    )