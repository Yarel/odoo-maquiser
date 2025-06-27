from odoo import models, fields

class MaquiserCompany(models.Model):
    _inherit = 'res.company'
    
    textile_specialization = fields.Selection([
        ('clothing', 'Prendas de Vestir'),
        ('technical', 'Textiles Técnicos'),
        ('uniforms', 'Uniformes')],
        string='Especialización Textil'
    )
    production_capacity = fields.Integer('Capacidad de Producción Diaria')
